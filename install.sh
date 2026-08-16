#!/usr/bin/env bash
# 安装「问答模式」(qa-mode) 预设到 DSH 用户预设目录
# Install the qa-mode preset into the DSH user preset root
set -euo pipefail
DSH_HOME_DIR="${DSH_HOME:-$HOME/.dsh}"
DEST="$DSH_HOME_DIR/.agent-presets/qa-mode"
SRC="$(cd "$(dirname "$0")" && pwd)/qa-mode"
if [ ! -d "$SRC" ]; then
  echo "未找到预设目录: $SRC" >&2
  exit 1
fi
mkdir -p "$DEST"
cp -R "$SRC"/. "$DEST"/
echo "已安装到: $DEST"
echo "请在 DSH 中新建会话，并选择预设「问答模式」。"
