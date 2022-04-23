#!/usr/bin/env pwsh -c

<#
.DESCRIPTION
    clean local branch.
.PARAMETER RemoveBranchNameRegex
    The regex to use to remove branch.
.PARAMETER Help
    Print help to console.
.EXAMPLE
    > .\bin\clean-branch.ps1 "JaimeZeng/*"
#>

param(
    [String] $RemoveBranchNameRegex
)

if (!$RemoveBranchNameRegex) { $RemoveBranchNameRegex = "JaimeZeng" }

# message
function info($msg) { write-host "INFO  $msg" -f darkgray }

# switch to master
git checkout -q master

# get a list of branches
$branch_list = Invoke-Expression -command "git branch"

# confirm branch which need to be removed
$branch_list | ForEach-Object {
    if ($_.EndsWith("master") -or $_.EndsWith("main") -or $_.EndsWith("version")) {
        info "'$_' branch, skipping ..."
    } elseif ($_ -match "$RemoveBranchNameRegex") {
        info "delete branch '$_' ..."
        Invoke-Expression -command "git branch --delete --force --quiet $_"
    } else {
        info "'$_' not match regexes '$RemoveBranchNameRegex', skipping ..."
    }
}

# print the remaining branches
git bvv -a
