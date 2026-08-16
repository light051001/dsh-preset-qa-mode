# 安装「问答模式」(qa-mode) 预设到 DSH 用户预设目录
# Install the qa-mode preset into the DSH user preset root
$ErrorActionPreference = 'Stop'
$dshHome = if ($env:DSH_HOME) { $env:DSH_HOME } else { Join-Path $env:USERPROFILE '.dsh' }
$dest = Join-Path $dshHome '.agent-presets\qa-mode'
$src = Join-Path $PSScriptRoot 'qa-mode'
if (-not (Test-Path $src)) { throw "未找到预设目录: $src" }
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Copy-Item -Path (Join-Path $src '*') -Destination $dest -Recurse -Force
Write-Host "已安装到: $dest"
Write-Host "请在 DSH 中新建会话，并选择预设「问答模式」。"
