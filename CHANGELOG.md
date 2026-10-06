# Changelog

本文件记录「问答模式」预设的各版本变更。格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，版本号遵循 [SemVer](https://semver.org/lang/zh-CN/)。

## [0.4.1] - 2026-08-17

修复「只有第一轮任务过关卡、后续任务擅自开始」的行为缺陷。人设文本自 v0.1.0 起从未改动，这是首次修改其结构。

### Fixed

- **堵掉「不提问就不过关卡」的旁路**：原文标题写「总结确认（开始执行前的必经关卡）」，正文却把它限定为「提问结束（或被打断）后」——自相矛盾。任务一旦无需提问，关卡就永远不触发，直接落到执行。现改为「凡会产生改动的任务，执行前必经此关，无一例外」，触发条件是「任务会产生改动」，与是否提问过无关。
- **补上「新任务」的定义**：新增「任务边界」一节。此前全篇只说「每次接到新任务必须执行」，却从未定义什么算新任务，于是「顺便把 X 也改了」这类补充被并进当前任务、不重走关卡。
- **给授权加过期**：明确「一次确认只授权一个任务；任务汇报完成后授权立即失效」。此前授权一旦发出就不过期，后续任务自然被吞掉。
- **关卡改为阻塞式**：总结确认以一次 `ask_user_question` 调用收尾（选项固定为「确认，开始执行」/「需要修正」/「跳过本次关卡」），用户作答前不得执行。跳过关卡由此从「一念之差」变成一次显式违规动作。
- **收紧「确认」的含义**：明确回答提问、点选选项、说「好」「可以」「行」都不构成确认。该表述与同版本 `standard` 预设 plan-mode 段落中的写法一致（"…approves nothing…"），此前 qa-mode 缺这一条。
- 限定「执行中发现新的歧义」一节只管**任务内部**的歧义：用户新提出的要求不是歧义，是新任务。
- 复杂任务的执行计划并入同一次总结确认关卡，避免两道审批。
- 补明「跳过本次关卡」的作用范围：只对当前这一个任务生效，下个任务照常过关。此前该选项的语义未在文本中定义。

### Changed

- README「行为协议」扩为 15 条（新增「任务边界」「确认的含义」，重写「总结确认」「执行」「执行中」）。
- CHECKLIST 第三节新增阻塞关卡、伪确认、第二轮任务重新过关、新任务识别、授权过期五项检查；用例表新增「连续任务」「伪确认」「顺便式补充」三行。

### Verified

- 以应用自带的 `js-yaml` + `!!js` schema 解析通过；19 行插件全部解析到已安装包。
- 分叉纪律保持：`plugins` 中除 `persona` 外的每一行仍与内置 `standard` 逐字节一致。

## [0.4.0] - 2026-08-17

适配 DSH `0.2.x`（桌面版 `0.2.0-rc.2`）：预设格式整体换代。

### Changed

- **预设改为声明式行**：DSH 0.2 移除了用户预设目录——全部安装包中已无任何代码读取 `$DSH_HOME/.agent-presets/`，放在那里的预设文件会被静默忽略。预设现在是 profile 组合里的一条 `@deepseek-ai/dsh-agent-preset` 声明。`qa-mode` 因此由 `agent.cordis.yml` 改为 `qa-mode.patch.yml`；安装即把它的 `insert` 区块写入 `$DSH_HOME/profiles/<profile>/cordis.patch.yml`，并在**重启应用后**生效。
- 与内置 `standard` 重新对齐，跟进 0.2 的能力变化：
  - `workflow-worker-thread` → `workflow-ptc`（`@deepseek-ai/dsh-workflow-ptc`）；`@deepseek-ai/dsh-workflow-worker-thread` 在 0.2 已不存在，沿用旧包名会让整条预设解析失败；
  - `tool-ralph` 跟随上游改为默认 `disabled: true`；
  - 新增 `tool-plugin-manager`（默认停用）行。
- 预设元数据 `name`（`问答模式`）/ `description` 从 `preset.yml` 移入声明行的 `config`；`order: 10` 让它在预设列表中排在四个内置预设之后。
- 安装脚本重写：自动探测 profile、写入前备份、以注释标记包围区块因而**可重复运行**（替换而非叠加），并显式写不带 BOM 的 UTF-8（避免 Windows PowerShell 5.1 给 YAML 加 BOM）。
- README 重写安装、自定义与兼容性章节；新增从 `app.asar` 取出内置 `standard` 预设做对齐的方法。

### Added

- `legacy-0.1.x/`：保留 DSH ≤ 0.1.5 可用的旧格式文件，并说明其在新版本上无效。

### Moved

- `qa-mode/agent.cordis.yml`、`qa-mode/preset.yml` → `legacy-0.1.x/`。

## [0.3.0] - 2026-08-17

适配 DSH `0.1.5-rc.2`：与内置 `standard` 预设重新对齐。

### Fixed

- **人设行迁移到新 schema（关键修复）**：`dsh-persona` 已不再接受 `config.text`，改为必填的 `config.prefix` 加 `config.suffix`。旧写法会让**整个预设挂载失败**（`invalid config: $.prefix missing required value`），选中「问答模式」的会话根本无法启动。现改为 `prefix` 承载身份句与全部协议、`suffix` 重申部署人设的工作目录句。
- 补齐 `/goal` 命令（`command-goal` 行）：Web 界面会停用宿主机的该行，由预设接管；此前只有 `tool-goal`，导致有目标工具却没有 `/goal` 命令。

### Added

- `present` 交付物声明工具（`@deepseek-ai/dsh-tool-present`）。
- 子代理 `modelSelectionSettings: true`：`subagent` 工具可为子代理单独选择模型。
- 网页抓取（`web_fetch`）：`tool-web` 的 `fetch` 恢复为标准模式的 `true`。

### Changed

- 可选的 Codex / Claude Code 子代理行按新 schema 改用 `backgroundMode: one-shot`（原 `enableRunInBackground` 写法）。
- `agent.cordis.yml` 顶部加入分叉说明与重新对齐方法，并在本地特有处标注 `[qa-mode]` 注释，便于随 DSH 升级同步。
- README 增加「兼容性」表与 `prefix`/`suffix` 自定义说明。

## [0.2.0] - 2026-08-16

### Added

- 引入四条零成本行为机制（移植自 Ouroboros 访谈流程，无需任何额外依赖）：
  - 来源纪律：回答先判定来源——能核实的现状事实自动采用，决策必问用户，总结按【你确认】/【代码事实】/【外部事实】/【我的假设】打标签；
  - 节奏护栏：连续 3 个问题自行查证/推断回答后，下一轮必须直接问用户；
  - 回显确认（Refine 门）：含推理/约束/边界的自由文本答案先结构化回显、确认无遗漏后再继续；
  - 一句话终检：总结末尾用一句话重述目标，用户终审后才进入执行，修正最多 2 轮。
- 执行阶段结果汇报同样采用来源标签。

## [0.1.0] - 2026-08-16

### Added

- 首个版本：以 DSH 内置 `standard` 预设为底版，完整保留全部能力。
- 人设与行为协议改写：
  - 每次任务先进行极其详尽的结构化提问（九大维度）；
  - 上限 5 轮提问、每轮 ≤ 10 问；
  - 支持随时打断（「跳过提问」「直接开始」等）；
  - 总结确认关卡：按维度复述要点，用户明确确认后才执行；
  - 小任务直接执行，复杂任务先出完整计划待批准；
  - 执行中仅重大歧义暂停提问，小歧义按合理默认处理并说明假设；
  - 语言与用户输入保持一致。
- 附验收检查清单（CHECKLIST.md）与示例会话（demo/示例会话.md）。
