# legacy-0.1.x — 旧版 DSH 专用（DSH ≤ 0.1.5）

> ⚠️ **这个目录里的文件对 DSH 0.2 及以后完全无效。** DSH 0.2 不再读取
> `$DSH_HOME/.agent-presets/`，扫描全部安装包也找不到任何对该目录的引用；
> 放在那里只会被静默忽略。
>
> **The files here do nothing on DSH 0.2+.** DSH 0.2 removed the user preset
> directory entirely; nothing in the app ever reads `$DSH_HOME/.agent-presets/`.
> Use `qa-mode/qa-mode.patch.yml` instead.

## 内容 / Contents

| 文件 | 说明 |
| --- | --- |
| `agent.cordis.yml` | DSH ≤ 0.1.5 的完整预设组合（`standard` 的分叉 + 问答人设） |
| `preset.yml` | 旧版展示元数据（`name` / `description`） |

## 安装（仅 DSH ≤ 0.1.5）/ Install on DSH ≤ 0.1.5

```powershell
# Windows
$dest = if ($env:DSH_HOME) { "$env:DSH_HOME\.agent-presets\qa-mode" } else { "$env:USERPROFILE\.dsh\.agent-presets\qa-mode" }
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Copy-Item .\legacy-0.1.x\agent.cordis.yml, .\legacy-0.1.x\preset.yml -Destination $dest
```

```bash
# macOS / Linux
dest="${DSH_HOME:-$HOME/.dsh}/.agent-presets/qa-mode"
mkdir -p "$dest" && cp legacy-0.1.x/agent.cordis.yml legacy-0.1.x/preset.yml "$dest"/
```

注意：`agent.cordis.yml` 里的 `persona` 行使用 `config.prefix` / `config.suffix`。
DSH **0.1.5** 起 `dsh-persona` 已移除 `config.text`，缺少必填的 `prefix` 会让整个
预设挂载失败；更早的版本请改用标签 `v0.1.0` / `v0.2.0` 的写法。

## 为什么保留 / Why keep it

Git 历史里本来就有这些文件（标签 `v0.3.0`），留在这里只是方便仍在 DSH ≤ 0.1.5 上
的用户直接取用，不必翻历史。当前主线已经不再维护它们。
