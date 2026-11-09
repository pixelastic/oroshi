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

	if len(fields) < 2 {
		return ""
	}
	return fields[1]
}
