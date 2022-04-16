# scoop-apps [![Tests](https://github.com/Ryanjiena/scoop-apps/actions/workflows/ci.yml/badge.svg)](https://github.com/Ryanjiena/scoop-apps/actions/workflows/ci.yml) [![Excavator](https://github.com/Ryanjiena/scoop-apps/actions/workflows/schedule.yml/badge.svg)](https://github.com/Ryanjiena/scoop-apps/actions/workflows/schedule.yml) [![Coding](https://badgen.net/badge/Coding/scoop-apps/green)](https://ryanjie.coding.net/public/scoop/scoop-apps/git/files)

## Installation / 安装

```powershell
scoop bucket add sapps https://github.com/Ryanjiena/scoop-apps
# for china users
scoop bucket add sapps https://e.coding.net/ryanjie/scoop/scoop-apps.git
cd $env:SCOOP\buckets\sapps\; git config pull.rebase true

# update bucket
scoop update
```

## Manifests / 清单

All manifests can be seached with `scoop search`.

```powershell
scoop search sapps/<app>

# Install scoop-completion (scoop tab completion) and scoop-search (fast `scoop search`)
scoop install scoop-completion scoop-search
scoop-search sapps/<app>
```

Install apps from this bucket with `scoop install`.

```powershell
scoop install sapps/<app>
```

## Apps / 应用

<details>
<summary>Apps</summary>

<!--ts-->
<!--te-->

</details>

![Visitor](https://profile-counter.glitch.me/Ryanjiena/count.svg)
