#!/usr/bin/env bash
# 安装「问答模式」(qa-mode) 预设到 DSH 0.2.x 的 profile 补丁层
# Install the qa-mode preset into a DSH 0.2.x profile patch layer.
#
# DSH 0.2 起预设不再是 $DSH_HOME/.agent-presets/ 下的独立文件，而是 profile 组合里
# 的声明式行；本脚本把 qa-mode 的 insert 区块写入
#   $DSH_HOME/profiles/<profile>/cordis.patch.yml
# 重复运行是安全的：已有区块会被整体替换，不会叠加。
#
# 用法: ./install.sh [profile名称]
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$HERE/qa-mode/qa-mode.patch.yml"
if [ ! -f "$SRC" ]; then
  echo "找不到预设补丁: $SRC" >&2
  exit 1
fi

DSH_HOME_DIR="${DSH_HOME:-$HOME/.dsh}"
PROFILES_DIR="$DSH_HOME_DIR/profiles"
PROFILE="${1:-${DSH_PROFILE:-}}"

# 未指定 profile 时自动探测：取唯一一个带 cordis.patch.yml 的 profile。
if [ -z "$PROFILE" ]; then
  candidates=()
  if [ -d "$PROFILES_DIR" ]; then
    for d in "$PROFILES_DIR"/*/; do
      [ -d "$d" ] || continue
      [ -f "${d}cordis.patch.yml" ] && candidates+=("$(basename "$d")")
    done
  fi
  if [ "${#candidates[@]}" -eq 1 ]; then
    PROFILE="${candidates[0]}"
  elif [ "${#candidates[@]}" -eq 0 ]; then
    echo "在 $PROFILES_DIR 下找不到任何带 cordis.patch.yml 的 profile；请传入 profile 名称。" >&2
    exit 1
  else
    echo "检测到多个 profile（${candidates[*]}）；请传入 profile 名称，例如: ./install.sh desktop" >&2
    exit 1
  fi
fi

PATCH="$PROFILES_DIR/$PROFILE/cordis.patch.yml"
if [ ! -f "$PATCH" ]; then
  echo "找不到 profile 补丁: $PATCH" >&2
  exit 1
fi
echo "目标 profile: $PROFILE"

START='# >>> dsh-preset-qa-mode'
END='# <<< dsh-preset-qa-mode <<<'

TMP_REST="$(mktemp)"
TMP_OUT="$(mktemp)"
trap 'rm -f "$TMP_REST" "$TMP_OUT"' EXIT

# 命令替换会去掉尾部空行，正好用来规整区块边界。
BODY="$(cat "$SRC")"
REST=""

if grep -qF "$START" "$PATCH"; then
  if ! grep -qF "$END" "$PATCH"; then
    echo "已存在的 qa-mode 区块缺少结束标记 $END，请手动检查 $PATCH" >&2
    exit 1
  fi
  # 丢掉旧区块（含起止标记），其余内容原样保留。
  awk -v s="$START" -v e="$END" '
    index($0, s) { skip = 1; next }
    skip && index($0, e) { skip = 0; next }
    !skip { print }
  ' "$PATCH" > "$TMP_REST"
  REST="$(cat "$TMP_REST")"
  MODE="替换了已有的 qa-mode 区块"
else
  REST="$(cat "$PATCH")"
  MODE="新增 qa-mode 区块"
fi

{
  printf '%s\n\n' "$REST"
  printf '%s\n' "$START"
  printf '%s\n' "$BODY"
  printf '%s\n' "$END"
} > "$TMP_OUT"

cp "$PATCH" "$PATCH.bak-qa-mode"
mv "$TMP_OUT" "$PATCH"

echo "已写入:  $PATCH"
echo "备份:    $PATCH.bak-qa-mode"
echo "（$MODE）"
echo
echo "下一步：重启 DeepSeek Harness，然后新建会话并选择预设「问答模式」。"
echo "若要卸载，删除 $PATCH 中 $START 与 $END 之间的区块即可（或还原备份）。"
