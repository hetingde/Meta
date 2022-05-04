#!/usr/bin/env pwsh -c
param(

    [String] $Upstream,
    [String] $App,
    [String] $Dir,
    [string[]] $SpecialSnowflakes
)

if (!$Upstream) { $Upstream = "Ryanjiena/scoop-apps:master" }
if (!$Dir) { $Dir = "$PSScriptRoot/../bucket" }

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

