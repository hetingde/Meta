# scoop-apps [![Tests](https://github.com/Ryanjiena/scoop-apps/actions/workflows/ci.yml/badge.svg)](https://github.com/Ryanjiena/scoop-apps/actions/workflows/ci.yml) [![Excavator](https://github.com/Ryanjiena/scoop-apps/actions/workflows/schedule.yml/badge.svg)](https://github.com/Ryanjiena/scoop-apps/actions/workflows/schedule.yml) <!-- [![Coding](https://badgen.net/badge/Coding/scoop-apps/green)](https://ryanjie.coding.net/public/scoop/scoop-apps/git/files) --> [![Visitors](https://komarev.com/ghpvc/?username=ryanjiena&color=brightgreen&style=flat&label=Visitors)](ttps://github.com/Ryanjiena/Ryanjiena)

## Installation / 安装

### Bucket

```powershell
scoop bucket add sapps https://github.com/Ryanjiena/scoop-apps
cd $env:SCOOP\buckets\sapps\; git config pull.rebase true

# update bucket
scoop update
```

### App

All manifests can be seached with `scoop search`.

```powershell
scoop search sapps/<app>

# Install scoop-completion (scoop tab completion) and scoop-search (fast `scoop search`)
scoop install scoop-completion scoop-search
scoop-search <app>
```

Install apps from this bucket with `scoop install`.

```powershell
scoop install sapps/<app>
```

## Manifests / 清单

<details>
<summary>Apps</summary>

<!--ts-->
<!--te-->

![Visitor](https://profile-counter.glitch.me/Ryanjiena/count.svg)

</details>

## 免责声明

根据中国《计算机软件保护条例》第十七条规定: "为了学习和研究软件内含的设计思想和原理, 通过安装、显示、传输或者存储软件等方式使用软件的, 可以不经软件著作权人许可, 不向其支付报酬."

软件均通过网络收集, 版权所有者归原作者, 仅供个人使用或学习研究, 请在 24h 内删除, 严禁商业或非法用途, 严禁用于打包恶意软件推广, 否则后果由用户承担责任.
