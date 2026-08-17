# DSH Preset：问答模式 (qa-mode) — Ask-First Clarification Agent

> 一个面向 [DeepSeek Harness (DSH)](https://github.com/deepseek-ai/deepseek-harness) 的智能体预设：接到任何任务都先进行极其详尽、结构化的提问，彻底澄清目的，经你明确确认后才开始执行。
>
> An agent preset for [DeepSeek Harness (DSH)](https://github.com/deepseek-ai/deepseek-harness): every task — big or small — starts with an exhaustive, structured Q&A to fully clarify your intent. It only starts working after you explicitly confirm.

## 这是什么 / What it is

「问答模式」以 DSH 内置的 `standard`（标准模式）预设为底版，**完整保留其全部能力**（文件编辑、Shell、文件与网页检索、Skills、计划模式、目标、子代理、工作流等），只改写了人设与行为规则（`agent.cordis.yml` 中的 `persona` 行）。

`qa-mode` is a copy of DSH's built-in `standard` preset with **every capability kept** (file editing, shell, file & web search, skills, plan mode, goals, subagents, workflows…). Only the persona / behavior rules are rewritten (the `persona` row in `agent.cordis.yml`).

## 行为协议 / Behavior protocol

1. **先问后做 / Ask first.** 接到任务后不直接执行，先用一两句话复述初步理解，然后进入提问。
2. **九大维度 / Nine dimensions.** 提问按需覆盖：① 目标与背景 ② 范围与边界 ③ 约束条件 ④ 偏好 ⑤ 验收标准 ⑥ 风险与兜底 ⑦ 执行方式偏好 ⑧ 沟通与详略偏好 ⑨ 上下文与背景信息。
3. **结构化提问 / Structured questions.** 使用 `ask_user_question` 给出带选项的选择题，推荐项置顶标注。
4. **上限 / Caps.** 最多 5 轮提问，每轮 ≤ 10 问；到达上限后停止提问，剩余不确定项写入总结请用户一并确认。
5. **随时打断 / Interruptible.** 用户随时可说「跳过提问」「直接开始」等，立即停止提问并进入总结确认。
6. **总结确认 / Confirmation gate.** 按维度分节复述理解要点，单列「仍不确定的项」与「默认假设」；用户明确确认后才执行，未确认不动任何东西。
7. **执行 / Execution.** 小任务确认后直接执行；复杂任务先输出完整执行计划，待用户批准后执行。
8. **执行中 / During execution.** 只有重大歧义才暂停提问；小歧义按合理默认处理并在结果中说明假设。
9. **语言 / Language.** 与用户输入语言保持一致。
10. **来源标签 / Source tags.** 能核实的现状事实自动采用、不打扰；决策必问用户；推断显式标为【我的假设】。
11. **节奏护栏 / Rhythm guard.** 连续 3 问自行查证/推断回答后，下一问必须直接问用户。
12. **回显确认 / Refine gate.** 含推理/约束/边界的自由文本答案，先结构化回显、确认无遗漏后再继续。
13. **一句话终检 / One-line restate.** 总结末尾用一句话重述目标，用户终审后才执行（修正最多 2 轮）。

## 安装 / Install

**要求 / Requirements**：已安装 DeepSeek Harness（DSH）。

**方式一：一键脚本 / Script**

Windows PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

macOS / Linux：

```bash
bash install.sh
```

**方式二：手动复制 / Manual**

把本仓库的 `qa-mode/` 目录整体复制到：

- Windows：`C:\Users\<你的用户名>\.dsh\.agent-presets\qa-mode\`
- macOS / Linux：`$HOME/.dsh/.agent-presets/qa-mode/`（若设置了 `DSH_HOME`，则为 `$DSH_HOME/.agent-presets/qa-mode/`）

然后**新建会话**，在预设列表中选择「问答模式」即可。注意：目录名必须保持 `qa-mode`；修改预设后需新建会话才能生效。

Copy the `qa-mode/` folder into `${DSH_HOME:-$HOME/.dsh}/.agent-presets/qa-mode/`, then start a **new session** and pick **问答模式** from the preset list. The folder name must stay `qa-mode`; changes take effect in new sessions only.

## 验收检查清单 / Acceptance checklist

见 [CHECKLIST.md](CHECKLIST.md) — 覆盖澄清阶段、打断与确认、执行阶段的完整检查项。

See [CHECKLIST.md](CHECKLIST.md).

## 演示 / Demo

- [demo/示例会话.md](demo/示例会话.md)：一个完整示例会话（提问 → 总结确认 → 执行，含打断示例）。
- `screenshots/`：预留目录，建议放入「预设选择界面」「一轮结构化提问」「总结确认」等截图。

## 自定义 / Customization

所有行为规则都在 `qa-mode/agent.cordis.yml` 的 `persona` 行（`config.text`）里，可直接修改：

- 调整提问轮次上限（默认 5 轮 / 每轮 ≤ 10 问）；
- 增删提问维度；
- 调整确认与执行规则；
- 元数据（名称、描述）在 `qa-mode/preset.yml`。

改完保存后，新建会话即生效。修改组合文件后建议先用 DSH 的挂载校验确认其有效。

## 致谢与许可 / Credits & License

- 底版来自 DeepSeek Harness 内置 `standard` 预设；DeepSeek Harness 以 MIT 许可开源：<https://github.com/deepseek-ai/deepseek-harness>
- v0.2.0 引入的四条澄清机制（来源标签、节奏护栏、回显确认、一句话终检）的设计思想借鉴自 [Q00/ouroboros](https://github.com/Q00/ouroboros)（MIT）——一个规范先行（spec-first）的 AI 开发工作流引擎；本预设以纯提示词重新实现，未复用其代码。
- 本仓库同样以 MIT 许可发布，见 [LICENSE](LICENSE)。

## 版本 / Versions

见 [CHANGELOG.md](CHANGELOG.md)。
