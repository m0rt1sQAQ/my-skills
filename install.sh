#!/usr/bin/env bash
# 把本仓库 skills/ 下的技能链到 DSH 技能目录（macOS / Linux）。
# 用法：./install.sh                 默认 ~/.dsh/skills
#       SKILLS_HOME=/path ./install.sh
#       ./install.sh --copy          复制而不是软链
#       ./install.sh --uninstall
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skills_home="${SKILLS_HOME:-$HOME/.dsh/skills}"
mode="link"

for arg in "$@"; do
  case "$arg" in
    --copy) mode="copy" ;;
    --uninstall) mode="uninstall" ;;
    -h|--help) sed -n '2,8p' "$0"; exit 0 ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

if [ ! -d "$repo_root/skills" ]; then
  echo "找不到技能目录：$repo_root/skills" >&2
  exit 1
fi

mkdir -p "$skills_home"

for dir in "$repo_root"/skills/*/; do
  name="$(basename "$dir")"
  target="$skills_home/$name"
  rm -rf "$target"

  if [ "$mode" = "uninstall" ]; then
    echo "removed  $name"
    continue
  fi

  if [ "$mode" = "copy" ]; then
    cp -R "${dir%/}" "$target"
    echo "copied   $name -> $target"
  else
    ln -s "${dir%/}" "$target"
    echo "linked   $name -> $target"
  fi
done

echo
echo "技能目录：$skills_home"
echo "改动本仓库的文件会立刻生效（软链模式）；重启会话后目录才会刷新。"
