## Scoop 介绍

[![ScoopInstaller/Scoop](https://github-readme-stats.vercel.app/api/pin/?username=ScoopInstaller&repo=Scoop&show_owner=true&theme=dracula)](https://github.com/ScoopInstaller/Scoop)

> 官方文档: [ScoopInstaller/scoop Wiki · GitHub](https://github.com/ScoopInstaller/Scoop/wiki#documentation)

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
scoop search <app>
# or
scoop install scoop-search
scoop-search <app>
```

## 查看软件信息

`scoop info <app>`

## 安装应用

`scoop install <app>`

## 卸载应用

`scoop uninstall <app>`

## 查看应用状态

`scoop status`

## 更新应用

```powershell
scoop update
scoop status
scoop update <app>
# or
scoop update *
```

## 禁止应用更新

```powershell
scoop hold <app>
# disable
scoop unhold <app>
```

## 切换软件保本

`scoop reset <app>`

## 查看已安装软件列表

`scoop list`

## 更多命令

```powershell
$ scoop help
alias       Manage scoop aliases
bucket      Manage Scoop buckets
cache       Show or clear the download cache
cat         Show content of specified manifest. If available, `bat` will be used to pretty-print the JSON.
checkup     Check for potential problems
cleanup     Cleanup apps by removing old versions
config      Get or set configuration values
create      Create a custom app manifest
depends     List dependencies for an app
download    Download apps in the cache folder and verify hashes
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
shim        Manipulate Scoop shims
status      Show status and check for new app versions
unhold      Unhold an app to enable updates
uninstall   Uninstall an app
update      Update apps, or Scoop itself
virustotal  Look for app's hash on virustotal.com
which       Locate a shim/executable (similar to 'which' on Linux)

Type 'scoop help <command>' to get help for a specific command.
```
