## Scoop 介绍

[![https://github.com/lukesampson/scoop](https://github-readme-stats.vercel.app/api/pin/?username=lukesampson&repo=scoop&show_owner=true&theme=dracula)](https://github.com/lukesampson/scoop)

> 官方文档: [lukesampson/scoop Wiki · GitHub](https://github.com/lukesampson/scoop/wiki#documentation)

Scoop 是一个 Win­dows 包管理工具(类似于 [Yum](http://yum.baseurl.org/index.html) 、[Homebrew](http://mxcl.github.io/homebrew/))。

使用 Scoop 来安装和管理我们的软件:

-   集搜索、下载、安装、更新软件于一体: 极大的降低了安装维护一个软件的成本，我们甚至不必在软件本身的复杂菜单中寻找那个更新按钮来更新软件自己
-   将软件干干净净的安装到电脑的「用户文件夹」下: 这样既不会污染路径也不会请求不必要的权限（UAC）
-   自动配置环境变量
-   在卸载软件的时候，能够尽量清空软件在电脑上存储的任何数据和痕迹

## 安装 Scoop

### 打开 PowerShell 远程权限

```powershell
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
```

### 自定义 Scoop 和 App 安装目录

Scoop 默认将 Scoop 和 App 安装在 `$HOME/scoop` 目录下。

```powershell
$env:SCOOP='D:\Applications\Scoop'
[Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'User')
```

### 安装 Scoop

```powershell
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')

# or shorter
iwr -useb get.scoop.sh | iex
```

## 常用命令

### 使用 aria2 多线程下载

```powershell
scoop install aria2
scoop config aria2-enabled true
# disable
# scoop config aria2-enabled false

scoop config aria2-retry-wait 4
scoop config aria2-split 16
scoop config aria2-max-connection-per-server 16
scoop config aria2-min-split-size 4M
```

## 搜索软件

```powershell
scoop search <app_name>
# or
scoop install scoop-search
scoop-search <app_name>
```

## 查看软件信息

`scoop info <app_name>`

## 安装应用

`scoop install <app_name>`

## 卸载应用

`scoop uninstall <app_name>`

## 查看应用状态

`scoop status`

## 更新应用

```powershell
scoop update
scoop status
scoop update <app_name>
# or
scoop update *
```

## 禁止应用更新

```powershell
scoop hold <app_name>
# disable
scoop unhold <app_name>
```

## 切换软件保本

`scoop reset <app_name>`

## 查看已安装软件列表

`scoop list`

## 导出应用列表

```powershell
function export-scoop {
    param (
        [parameter(Mandatory = $true)]
        [string] $filepath
    )
    # $file = (Test-Path $filepath) ? "$filepath" : "$profileDir\scoop_app"
    $file = ($filepath) ? "$filepath" : "$profileDir\scoop_app"
    $apps = scoop export | awk '{print $1}' | Join-String -Separator " "
    Write-Output $apps > $file
    $msg = (Test-Path $file) ? "Success" : "Fail"
    Write-Output $msg
}
export-scoop
```

## 导入应用列表

```powershell
function import-scoop {
    param(
        [parameter(Mandatory = $true)]
        [string] $filepath
    )

    if (Test-Path "$profileDir\scoop_app") {
        $file = "$profileDir\scoop_app"
    }

    $apps = Get-Content $file
    $cmd = "scoop install " + $apps
    Invoke-Expression $cmd
}
import-scoop
```

## 更多命令

```powershell
$ scoop help
alias       Manage scoop aliases
bucket      Manage Scoop buckets
cache       Show or clear the download cache
checkup     Check for potential problems
cleanup     Cleanup apps by removing old versions
config      Get or set configuration values
create      Create a custom app manifest
depends     List dependencies for an app
export      Exports (an importable) list of installed apps
help        Show help for a command
hold        Hold an app to disable updates
home        Opens the app homepage
info        Display information about an app
install     Install apps
list        List installed apps
prefix      Returns the path to the specified app
reset       Reset an app to resolve conflicts
search      Search available apps
status      Show status and check for new app versions
unhold      Unhold an app to enable updates
uninstall   Uninstall an app
update      Update apps, or Scoop itself
virustotal  Look for app's hash on virustotal.com
which       Locate a shim/executable (similar to 'which' on Linux)

Type 'scoop help <command>' to get help for a specific command.
```
