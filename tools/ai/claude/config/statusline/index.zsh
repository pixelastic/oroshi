#!/usr/bin/env zsh
# Entry point of the Claude Code statusline, sources the main.zsh of the current OROSHI_ROOT
# Usage:
# $ index.zsh < status.json  # Render from the Claude Code statusLine JSON
# $ index.zsh --dry-run      # Render with fake session data
set -e

source "$OROSHI_ROOT/tools/ai/claude/config/statusline/main.zsh"
