#!/usr/bin/env pwsh -c

<#
.DESCRIPTION
    Adds/Updates manifests and pushes them to the specified branch.

.PARAMETER Upstream
    Upstream repository with the target branch.
    Must be in format '<user>/<repo>:<branch>'

.PARAMETER App
    Manifest name to search.

.PARAMETER Dir
    The directory where to search for manifests.

.PARAMETER SpecialSnowflakes
    An array of manifests, which should be updated all the time. (-ForceUpdate parameter to checkver)

.PARAMETER PRBranchName
    The name of the github branch the changes are being put into.

.PARAMETER Push
    Push updates directly to 'origin $PRBranchName'.

.PARAMETER Request
    Create pull-requests on 'upstream branch'.

.PARAMETER RepoName
    The name of the repository.(e.g. "Ryanjiena/Meta" or "github.com/Ryanjiena/Meta")

.PARAMETER Base
    The name of the branch you want the changes pulled into. This should be an existing branch on the current repository. You cannot submit a pull request to one repository that requests a merge to a base of another repository.

.PARAMETER Modify
    Indicates whether maintainers can modify the pull request.

.PARAMETER Draft
    Indicates whether the pull request is a draft.

.PARAMETER AuthToken
    A personal access token

.PARAMETER Help
    Print help to console.
.LINK
    https://docs.github.com/en/rest/pulls/pulls#create-a-pull-request
#>

param(
    [String] $Upstream,
    [String] $App,
    [String] $Dir,
    [string[]] $SpecialSnowflakes,
    [String] $PRBranchName,
    [Switch] $Push,
    [Switch] $Request,
    [String] $RepoName,
    [String] $Base,
    [Switch] $Modify,
    [String] $AuthToken,
    [Switch] $Help
)

if ($Help) {
    Write-Host @'
Usage: branch-push.ps1 [OPTION]

Optional options:
  -Upstream           Upstream repository with the target branch. Must be in format '<user>/<repo>:<branch>'
  -App                Manifest name to search.
  -Dir                The directory where to search for manifests.
  -SpecialSnowflakes  An array of manifests, which should be updated all the time. (-ForceUpdate parameter to checkver)
  -PRBranchName       The name of the github branch the changes are being put into.
  -Push               Push updates directly to 'origin $PRBranchName'.
  -Request            Create pull-requests on 'upstream branch'.
  -RepoName           The name of the repository.(e.g. "Ryanjiena/Meta" or "github.com/Ryanjiena/Meta")
  -Base               The name of the branch you want the changes pulled into. This should be an existing branch on the current repository. You cannot submit a pull request to one repository that requests a merge to a base of another repository.
  -Modify             Indicates whether maintainers can modify the pull request.
  -Draft              Indicates whether the pull request is a draft.
  -AuthToken          A personal access token
  -Help               Print help to console.

Example:
  ./bin/branch-push.ps1 -Upstream 'Ryanjiena/Scoop-apps:master' -App 'clash' -PRBranchName 'JaimeZeng/clash' -Push -Request -RepoName 'github.com/Ryanjiena/Scoop-apps' -Base 'master' -AuthToken 'Github PAT'
  ./bin/branch-push.ps1 -Upstream 'Ryanjiena/Scoop-apps:master' -SpecialSnowflakes 'clash,clashn,...' -PRBranchName 'JaimeZeng/clash' -Push -Request -RepoName 'github.com/Ryanjiena/Scoop-apps' -Base 'master' -AuthToken 'Github PAT'
  ./bin/branch-push.ps1 -Upstream 'Ryanjiena/Scoop-apps:master' -SpecialSnowflakes 'clash,clashn,...' -PRBranchName 'JaimeZeng/clash' -Push -Request -RepoName 'github.com/Ryanjiena/Scoop-apps' -Base 'master' -Modify -Draft -AuthToken 'Github PAT'
'@
    exit 0
}

if (!$Upstream) { $Upstream = "Ryanjiena/scoop-apps:master" }
if (!$Dir) { $Dir = "$PSScriptRoot/../bucket" }
if (($App) -and (!$PRBranchName)) { $PRBranchName = "JaimeZeng/$App" }
if (($Request) -and (!(scoop which gh))) {
    Write-Host "Please install hub 'scoop install gh'" -ForegroundColor Yellow
    exit 1
}
if (!$RepoName) { $RepoName = "github.com/Ryanjiena/Scoop-apps" }
if (!$Base) { $Base = "master" }
# message
function abort($msg, [int] $exit_code = 1) { write-host $msg -f red; exit $exit_code }
function error($msg) { write-host "ERROR $msg" -f darkred }
function warn($msg) { write-host "WARN  $msg" -f darkyellow }
function info($msg) { write-host "INFO  $msg" -f darkgray }
function success($msg) { write-host $msg -f darkgreen }

# run command and return output
function execute($cmd) {
    Write-Host $cmd -ForegroundColor Green
    $output = Invoke-Expression $cmd

    if ($LASTEXITCODE -gt 0) {
        abort "^^^ Error! See above ^^^ (last command: $cmd)"
    }

    return $output
}

# parse manifest
function parse_json($path) {
    if (!(test-path $path)) { return $null }
    Get-Content $path -raw -Encoding UTF8 | convertfrom-json -ea stop
}

function parse_repo($RepoName) {

    $Parts = $RepoName.Split("/")
    $Result = @{}

    switch ($Parts.Length) {
        2 {
            $Result.Server = "github.com"
            $Result.Owner = $parts[0]
            $Result.Repo = $parts[1]
        }

        3 {
            $Result.Server = $parts[0]
            $Result.Owner = $parts[1]
            $Result.Repo = $parts[2]
        }

        default {
            throw "Invalid RepoName: $RepoName"
        }
    }

    return $Result
}

# commit manifest
function commit_manifest($App) {
    $manifest = "$Dir/$App.json"

    $json = parse_json $manifest
    if (!$json.version) {
        write-host "ERROR Invalid manifest: $manifest ..." -f darkred
        return
    }
    $version = $json.version

    Write-Host "Creating add $App ($version) ..." -ForegroundColor DarkCyan
    execute "git add $manifest"

    # detect if file was staged, because it's not when only LF or CRLF have changed
    $status = execute 'git status --porcelain -uno $manifest'

    # confirm add or update
    if ($status -and $status.StartsWith('A  ') -and $status.EndsWith("$App.json")) {
        execute "git commit -m '${App}: Add to version $version'"
    } elseif ($status -and $status.StartsWith('M  ') -and $status.EndsWith("$App.json")) {
        execute "git commit -m '${App}: Update to version $version'"
    } else {
        Write-Host "Skipping $App because only LF/CRLF changes were detected ..." -ForegroundColor Yellow
    }
}

# switch to $PRBranchName branch
execute "git checkout -b $PRBranchName"

# commit one manifest
if ($App) {
    . "$PSScriptRoot\checkver.ps1" $App -u
    commit_manifest $App
}

# commit an array of manifests
if ($SpecialSnowflakes) {
    Write-Host "Forcing update on our special snowflakes: $($SpecialSnowflakes -join ',')" -ForegroundColor DarkCyan
    $SpecialSnowflakes -split ',' | ForEach-Object {
        $App = "$_"
        . "$PSScriptRoot\checkver.ps1" $App -u
        commit_manifest $App
    }
}

# push update to 'origin $PRBranchName'
if ($Push) {
    Write-Host 'Pushing updates ...' -ForegroundColor DarkCyan
    execute "git push origin $PRBranchName"
}

# create pull-request
if ($Request) {
    Write-Host 'gh login with token...' -ForegroundColor DarkCyan
    Write-Output "$AuthToken" | gh auth login --with-token

    Write-Host 'Creating pull-request ...' -ForegroundColor DarkCyan
    if ($App) {
        $manifest = "$Dir/$App.json"
        $json = parse_json $manifest
        $version = $json.version
        $PRTitle = "${App}: Add version $version"
    }

    if ($SpecialSnowflakes) {
        $PRTitle = "Add $SpecialSnowflakes"
    }

    $OFS = "`r`n"
    git log --graph --topo-order --date=short --abbrev-commit --decorate --boundary --pretty=format:'%Cgreen%s %Cblue[%cn]%Creset %Cblue%G?%Creset' master..$PRBranchName > PrBodyFile
    Write-Output "${OFS} - [x] I have read the [Contributing Guide](https://github.com/ScoopInstaller/.github/blob/main/.github/CONTRIBUTING.md)." >> PrBodyFile

    # $Result = parse_repo $RepoName
    # $Server = $Result.Server
    # $Owner = $Result.Owner
    # $Repo = $Result.Repo

    if (!$Modify) { $Params += "--no-maintainer-edit" }
    if ($Draft) { $Params += "--draft" }

    # gh pr create --repo $Server/$Owner/$Repo --title "${PRTitle}" --head $PRBranchName --base $Base --body-file PrBodyFile --fill
    gh pr create --title "${PRTitle}" --head $PRBranchName --base $Base --body-file PrBodyFile --fill

    # clean up
    Remove-Item PrBodyFile -Force

    Write-Host 'Logging out ...' -ForegroundColor DarkCyan
    Write-Output "Y" | gh auth logout --hostname github.com
}

git checkout -q master
