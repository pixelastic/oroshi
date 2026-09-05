package shebang

import (
	"path/filepath"
	"strings"
)

// Interpreter extracts the interpreter name from a shebang line.
// Returns "" if the line is not a valid shebang.
//
// Examples:
//
//	"#!/bin/zsh"               → "zsh"
//	"#!/usr/bin/env python3"   → "python3"
//	"#!/usr/bin/env -S node"   → "node"
func Interpreter(firstLine string) string {
	if !strings.HasPrefix(firstLine, "#!") {
		return ""
	}
	rest := strings.TrimSpace(firstLine[2:])
	if rest == "" {
		return ""
	}

	fields := strings.Fields(rest)
	bin := filepath.Base(fields[0])

	if bin != "env" {
		return bin
	}

	// Skip flags after env (e.g. -S, -u)
	for _, arg := range fields[1:] {
		if !strings.HasPrefix(arg, "-") {
			return arg
		}
	}
	return ""
}
