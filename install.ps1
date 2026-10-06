# 安装「问答模式」(qa-mode) 预设到 DSH 0.2.x 的 profile 补丁层
# Install the qa-mode preset into a DSH 0.2.x profile patch layer.
#
# DSH 0.2 起预设不再是 $DSH_HOME/.agent-presets/ 下的独立文件，而是 profile 组合里
# 的声明式行；本脚本把 qa-mode 的 insert 区块写入
#   $DSH_HOME/profiles/<profile>/cordis.patch.yml
# 重复运行是安全的：已有区块会被整体替换，不会叠加。
[CmdletBinding()]
param(
    # 目标 profile 名；默认为 $env:DSH_PROFILE，未设置时自动探测。
    # 注意不要改名为 $Profile —— 那是 PowerShell 的自动变量，会干扰参数绑定。
    [string]$ProfileName = $env:DSH_PROFILE
)

$ErrorActionPreference = 'Stop'

$root = $PSScriptRoot
$src = Join-Path $root 'qa-mode/qa-mode.patch.yml'
if (-not (Test-Path $src)) { throw "找不到预设补丁: $src" }

$dshHome = if ($env:DSH_HOME) { $env:DSH_HOME } else { Join-Path $env:USERPROFILE '.dsh' }
$profilesDir = Join-Path $dshHome 'profiles'

# 未指定 profile 时自动探测：优先唯一一个带 cordis.patch.yml 的 profile。
if (-not $ProfileName) {
    $candidates = @()
    if (Test-Path $profilesDir) {
        $candidates = @(Get-ChildItem $profilesDir -Directory |
            Where-Object { Test-Path (Join-Path $_.FullName 'cordis.patch.yml') } |
            Select-Object -ExpandProperty Name)
    }
    if ($candidates.Count -eq 1) {
        $ProfileName = $candidates[0]
    } elseif ($candidates.Count -eq 0) {
        throw "在 $profilesDir 下找不到任何带 cordis.patch.yml 的 profile；请用 -ProfileName <名称> 指定。"
    } else {
        throw "检测到多个 profile（$($candidates -join ', ')）；请用 -ProfileName <名称> 指定，例如 -ProfileName desktop。"
    }
}

$patch = Join-Path $profilesDir "$ProfileName/cordis.patch.yml"
if (-not (Test-Path $patch)) { throw "找不到 profile 补丁: $patch" }
Write-Host "目标 profile: $ProfileName"

$start = '# >>> dsh-preset-qa-mode'
$end = '# <<< dsh-preset-qa-mode <<<'
# 必须显式按 UTF-8 读取：Windows PowerShell 5.1 的 Get-Content 在没有 BOM 时按系统
# ANSI 代码页解码，会把预设里的中文人设读成乱码再写回去 —— YAML 依然能解析，所以
# 不会报错，人设却已经损坏。
$body = [System.IO.File]::ReadAllText($src, [System.Text.Encoding]::UTF8).TrimEnd()
$block = "$start`n$body`n$end"

$current = [System.IO.File]::ReadAllText($patch, [System.Text.Encoding]::UTF8)
$hadBlock = $current.Contains($start)
if ($hadBlock) {
    $s = $current.IndexOf($start)
    $e = $current.IndexOf($end)
    if ($e -lt 0) { throw "已存在的 qa-mode 区块缺少结束标记 $end，请手动检查 $patch" }
    $updated = $current.Substring(0, $s) + $block + $current.Substring($e + $end.Length)
} else {
    $updated = $current.TrimEnd() + "`n`n" + $block + "`n"
}

$backup = "$patch.bak-qa-mode"
Copy-Item $patch $backup -Force
# 显式写不带 BOM 的 UTF-8，避免 Windows PowerShell 5.1 给 YAML 加上 BOM。
[System.IO.File]::WriteAllText($patch, $updated, (New-Object System.Text.UTF8Encoding($false)))

Write-Host "已写入:  $patch"
Write-Host "备份:    $backup"
if ($hadBlock) { Write-Host "（替换了已有的 qa-mode 区块）" } else { Write-Host "（新增 qa-mode 区块）" }
Write-Host ""
Write-Host "下一步：重启 DeepSeek Harness，然后新建会话并选择预设「问答模式」。"
Write-Host "若要卸载，删除 $patch 中 $start 与 $end 之间的区块即可（或还原备份）。"
