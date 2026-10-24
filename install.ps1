# 把本仓库 skills/ 下的技能挂到 DSH 技能目录（Windows / PowerShell 5.1+）。
# 用法：.\install.ps1            默认安装到 ~/.dsh/skills
#       .\install.ps1 -SkillsHome "D:\other\skills"  -Copy
param(
    [string]$SkillsHome = (Join-Path $HOME '.dsh\skills'),
    [switch]$Copy,
    [switch]$Uninstall
)

$repoRoot = $PSScriptRoot
$src = Join-Path $repoRoot 'skills'

if (-not (Test-Path $src)) {
    Write-Error "找不到技能目录：$src"
    exit 1
}

if (-not (Test-Path $SkillsHome)) {
    New-Item -ItemType Directory -Force -Path $SkillsHome | Out-Null
}

$skills = Get-ChildItem $src -Directory
if ($skills.Count -eq 0) {
    Write-Error "skills 目录下没有任何技能"
    exit 1
}

foreach ($skill in $skills) {
    $target = Join-Path $SkillsHome $skill.Name

    if (Test-Path $target) {
        $item = Get-Item $target -Force
        if ($item.LinkType -eq 'Junction' -or $item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            cmd /c rmdir "$target" | Out-Null
        } else {
            Remove-Item $target -Recurse -Force
        }
    }

    if ($Uninstall) {
        Write-Host "removed  $($skill.Name)"
        continue
    }

    if ($Copy) {
        Copy-Item $skill.FullName -Destination $target -Recurse -Force
        Write-Host "copied   $($skill.Name) -> $target"
    } else {
        New-Item -ItemType Junction -Path $target -Target $skill.FullName | Out-Null
        Write-Host "linked   $($skill.Name) -> $target"
    }
}

if (-not $Uninstall) {
    Write-Host ""
    Write-Host "技能目录：$SkillsHome"
    Write-Host "改动本仓库的文件会立刻生效（junction 模式）；重启会话后目录才会刷新。"
}
