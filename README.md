# DSH Preset：问答模式 (qa-mode) — Ask-First Clarification Agent

> 一个面向 [DeepSeek Harness (DSH)](https://github.com/deepseek-ai/deepseek-harness) 的智能体预设：接到任何任务都先进行极其详尽、结构化的提问，彻底澄清目的，经你明确确认后才开始执行。
>
> An agent preset for [DeepSeek Harness (DSH)](https://github.com/deepseek-ai/deepseek-harness): every task — big or small — starts with an exhaustive, structured Q&A to fully clarify your intent. It only starts working after you explicitly confirm.

## 这是什么 / What it is

「问答模式」以 DSH 内置的 `standard`（标准模式）预设为底版，**完整保留其全部能力**（文件编辑、Shell、文件与网页检索、网页抓取、Skills、计划模式、目标与 `/goal` 命令、子代理、工作流、交付物声明等），只改写了人设与行为规则（`qa-mode.patch.yml` 中 `plugins` 的 `persona` 行）。

`qa-mode` is a copy of DSH's built-in `standard` preset with **every capability kept** (file editing, shell, file & web search, web fetch, skills, plan mode, goals and the `/goal` command, subagents, workflows, deliverables…). Only the persona / behavior rules are rewritten (the `persona` row in `qa-mode.patch.yml`).

## 行为协议 / Behavior protocol

1. **先问后做 / Ask first.** 接到任务后不直接执行，先用一两句话复述初步理解，然后进入提问。
2. **九大维度 / Nine dimensions.** 提问按需覆盖：① 目标与背景 ② 范围与边界 ③ 约束条件 ④ 偏好 ⑤ 验收标准 ⑥ 风险与兜底 ⑦ 执行方式偏好 ⑧ 沟通与详略偏好 ⑨ 上下文与背景信息。
3. **结构化提问 / Structured questions.** 使用 `ask_user_question` 给出带选项的选择题，推荐项置顶标注。
4. **上限 / Caps.** 最多 5 轮提问，每轮 ≤ 10 问；到达上限后停止提问，剩余不确定项写入总结请用户一并确认。
5. **随时打断 / Interruptible.** 用户随时可说「跳过提问」「直接开始」等，立即停止提问并进入总结确认。
6. **总结确认 / Confirmation gate.** **凡会产生改动的任务必经此关**，与是否提问过无关：按维度分节复述理解要点，单列「仍不确定的项」与「默认假设」，并以一次 `ask_user_question` 阻塞式提问收尾（确认，开始执行 / 需要修正 / 跳过本次关卡）；用户作答前不动任何东西。「跳过本次关卡」只对当前这一个任务生效，下个任务照常过关。
7. **任务边界 / Task boundary.** 一条新消息只要含新的改动意图就是新任务——哪怕它紧接着上一个任务，哪怕以「顺便」「还有」「对了」开头；一次确认只授权一个任务，任务汇报完成后授权立即失效。
8. **确认的含义 / What counts as confirmation.** 回答提问、点选选项、说「好」「可以」「行」都不构成确认；只有明确的「确认」「开始」才算。
9. **执行 / Execution.** 小任务确认后直接执行；复杂任务的执行计划写进同一次总结确认，一次确认即可开工，不设第二道审批。
10. **执行中 / During execution.** 只有重大歧义才暂停提问；小歧义按合理默认处理并在结果中说明假设。用户新提出的要求不是歧义，是新任务。
11. **语言 / Language.** 与用户输入语言保持一致。
12. **来源标签 / Source tags.** 能核实的现状事实自动采用、不打扰；决策必问用户；推断显式标为【我的假设】。
13. **节奏护栏 / Rhythm guard.** 连续 3 问自行查证/推断回答后，下一问必须直接问用户。
14. **回显确认 / Refine gate.** 含推理/约束/边界的自由文本答案，先结构化回显、确认无遗漏后再继续。
15. **一句话终检 / One-line restate.** 总结末尾用一句话重述目标，用户终审后才执行（修正最多 2 轮）。

## 安装 / Install

**要求 / Requirements**：DSH **0.2.x**（桌面版或 CLI）。仍在 DSH ≤ 0.1.5 上请改用 [legacy-0.1.x/](legacy-0.1.x/) 或标签 `v0.3.0`。

DSH 0.2 起，预设不再是一个独立文件，而是 profile 组合里的一行声明。安装 = 把 qa-mode 的 `insert` 区块写进该 profile 的补丁层：

- Windows：`C:\Users\<用户名>\.dsh\profiles\<profile>\cordis.patch.yml`
- macOS / Linux：`${DSH_HOME:-$HOME/.dsh}/profiles/<profile>/cordis.patch.yml`

（桌面版的应用内 profile 名为 `desktop`。）

**方式一：一键脚本 / Script**（自动探测 profile、自动备份、可重复运行）

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

```bash
bash install.sh
```

**方式二：手动 / Manual**

把 `qa-mode/qa-mode.patch.yml` 的全部内容追加到上面那个 `cordis.patch.yml` 末尾即可——该文件是一个 YAML 数组，追加一个 `- insert:` 条目就是新增一个预设。

**然后重启 DeepSeek Harness**（profile 只在启动时组合一次），再**新建会话**，在预设列表中选择「问答模式」。

Restart DSH after installing — the profile is composed once at boot — then start a **new session** and pick **问答模式**.

**确认生效 / Verify**：预设列表出现「问答模式」。若是红色「损坏」徽标，把鼠标停上去会显示具体原因（通常是某个插件包解析失败或配置不合 schema）。

**卸载 / Uninstall**：删除 `cordis.patch.yml` 中 `# >>> dsh-preset-qa-mode` 与 `# <<< dsh-preset-qa-mode <<<` 之间的区块，或还原安装脚本生成的备份 `cordis.patch.yml.bak-qa-mode`，再重启。

## 验收检查清单 / Acceptance checklist

见 [CHECKLIST.md](CHECKLIST.md) — 覆盖澄清阶段、打断与确认、执行阶段的完整检查项。

See [CHECKLIST.md](CHECKLIST.md).

## 演示 / Demo

- [demo/示例会话.md](demo/示例会话.md)：一个完整示例会话（提问 → 总结确认 → 执行，含打断示例）。
- `screenshots/`：预留目录，建议放入「预设选择界面」「一轮结构化提问」「总结确认」等截图。

## 自定义 / Customization

所有行为规则都在 `qa-mode/qa-mode.patch.yml` 里 `config.plugins` 的 `persona` 行，分两段：

- `config.prefix`：身份句 + 全部澄清协议、总结确认、执行与语言规则（**要改的通常就是这里**）；
- `config.suffix`：`Your working directory is {{cwd}}.`——部署默认人设的工作目录句，预设会整体遮蔽部署人设，所以这一句必须在此重申。

Every behavior rule lives in the `persona` row's `config`: `prefix` carries the identity sentence plus the whole clarification protocol, and `suffix` restates the deployment's working-directory sentence (a preset shadows the deployment persona outright, so omitting it drops that line).

可直接修改：

- 调整提问轮次上限（默认 5 轮 / 每轮 ≤ 10 问）；
- 增删提问维度；
- 调整确认与执行规则；
- 元数据：同一个 `insert` 行 `config` 下的 `name`（预设列表里显示的名字）与 `description`。

改完保存后，**重跑一次安装脚本**（它会替换旧区块，不会叠加），重启 DSH，再新建会话。

> ⚠️ 两个易踩的坑：
> 1. 不要改回旧版的 `config.text`——`dsh-persona` 只接受 `prefix` / `suffix` / `complete` / `includeRuntimeContext`，缺少必填的 `prefix` 会让**整个预设挂载失败**（预设卡片显示「损坏」，选中它的会话起不来）。
> 2. `plugins` 里每个 `name` 都必须是**已安装**的插件包。写错一个包名，整条预设就会解析失败——这正是 DSH 0.2 把 `workflow-worker-thread` 换成 `workflow-ptc` 时最容易漏掉的地方。

## 兼容性 / Compatibility

| 预设版本 | 适配的 DSH | 安装方式 | 说明 |
| --- | --- | --- | --- |
| **0.4.0** | **0.2.x**（含桌面版 0.2.0-rc.2） | 写入 profile 的 `cordis.patch.yml` | 改为 0.2 的声明式 `dsh-agent-preset` 行；跟进 `workflow-ptc`、`tool-ralph` 默认停用、`tool-plugin-manager` 等变化 |
| 0.3.0 | 0.1.5-rc.2 | `~/.dsh/.agent-presets/qa-mode/agent.cordis.yml` | 人设行迁移到 `prefix`/`suffix`；补齐 `/goal`、`present`、模型选择、网页抓取 |
| 0.2.0 / 0.1.0 | ≤ 0.1.4 | 同上 | 使用已移除的 `config.text`，在 DSH ≥ 0.1.5 上**无法挂载** |

> 0.2 起 `~/.dsh/.agent-presets/` **彻底失效**：整个应用不再有任何代码读取它，放在那里的预设文件会被静默忽略。仍在用 0.1.x 的用户请取标签 `v0.3.0`。

`qa-mode/qa-mode.patch.yml` 是 `standard` 的**分叉（fork）**：它 `plugins` 列表里的每一行都应与同版本 DSH 的 `standard` 预设完全一致，唯一的差异是 `persona` 行。DSH 升级后建议重新对齐——0.2 起内置预设打包在 `app.asar` 内，需要先取出来：

```bash
# 桌面版：用应用自带的 Electron 作为 Node 读 asar
ELECTRON_RUN_AS_NODE=1 "/path/to/DeepSeek Harness" -e \
  "process.stdout.write(require('fs').readFileSync('<install>/resources/app.asar/dsh/node_modules/@deepseek-ai/dsh-web-app/presets/standard.patch.yml','utf8'))" \
  > standard.patch.yml
diff standard.patch.yml qa-mode/qa-mode.patch.yml
```

除 `persona` 行与顶部分叉说明外，任何差异都说明 `standard` 新增或调整了能力而本预设尚未跟进。

The preset is a **fork of `standard`**: every row in its `plugins` list should match the same DSH version's `standard` preset, with the `persona` row as the only intentional difference. Re-diff after each DSH upgrade; anything else differing is drift.

## 致谢与许可 / Credits & License

- 底版来自 DeepSeek Harness 内置 `standard` 预设；DeepSeek Harness 以 MIT 许可开源：<https://github.com/deepseek-ai/deepseek-harness>
- v0.2.0 引入的四条澄清机制（来源标签、节奏护栏、回显确认、一句话终检）的设计思想借鉴自 [Q00/ouroboros](https://github.com/Q00/ouroboros)（MIT）——一个规范先行（spec-first）的 AI 开发工作流引擎；本预设以纯提示词重新实现，未复用其代码。
- 本仓库同样以 MIT 许可发布，见 [LICENSE](LICENSE)。

## 版本 / Versions

见 [CHANGELOG.md](CHANGELOG.md)。
