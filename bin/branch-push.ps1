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
.PARAMETER Help
    Print help to console.
#>

param(
    [String] $Upstream,
    [String] $App,
    [String] $Dir,
    [string[]] $SpecialSnowflakes,
    [String] $PRBranchName,
    [Switch] $Push,
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
  -Help               Print help to console.

Example:
  ./bin/branch-push.ps1 -App "clash" -PRBranchName "JaimeZeng/clash -Push"
  ./bin/branch-push.ps1 -SpecialSnowflakes "clash, ..." -PRBranchName "JaimeZeng/clash"
'@
    exit 0
}

if (!$Upstream) { $Upstream = "Ryanjiena/scoop-apps:master" }
if (!$Dir) { $Dir = "$PSScriptRoot/../bucket" }
if (($App) -and (!$PRBranchName)) { $PRBranchName = "JaimeZeng/$App" }

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
    $status = execute 'git status --porcelain -uno'
    $status = $status | Where-Object { $_ -match "A\s{2}.*$App.json" }

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
    . "$PSScriptRoot\checkver.ps1" $App -u -f
    commit_manifest $App
}

# commit an array of manifests
if ($SpecialSnowflakes) {
    Write-Host "Forcing update on our special snowflakes: $($SpecialSnowflakes -join ',')" -ForegroundColor DarkCyan
    $SpecialSnowflakes -split ',' | ForEach-Object {
        $App = "$_"
        . "$PSScriptRoot\checkver.ps1" $App -u -f
        commit_manifest $App
    }
}

# push update to 'origin $PRBranchName'
if ($Push) {
    Write-Host 'Pushing updates ...' -ForegroundColor DarkCyan
    execute "git push origin $PRBranchName"
}

# print pull request message
execute "git log --graph --topo-order --date=short --abbrev-commit --decorate --boundary --pretty=format:'%Cgreen%s %Cblue[%cn]%Creset %Cblue%G?%Creset' master..$PRBranchName"
$msg = "- [x] I have read the [Contributing Guide](https://github.com/ScoopInstaller/.github/blob/main/.github/CONTRIBUTING.md)."
Write-Host $msg -ForegroundColor DarkCyan
