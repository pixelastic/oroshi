package shebang

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestParsesDirectZshPath(t *testing.T) {
	assert.Equal(t, "zsh", Interpreter("#!/bin/zsh"))
}

func TestParsesDirectBashPath(t *testing.T) {
	assert.Equal(t, "bash", Interpreter("#!/bin/bash"))
}

func TestParsesDirectShPath(t *testing.T) {
	assert.Equal(t, "sh", Interpreter("#!/bin/sh"))
}

func TestParsesUsrBinPath(t *testing.T) {
	assert.Equal(t, "zsh", Interpreter("#!/usr/bin/zsh"))
}

func TestParsesEnvZsh(t *testing.T) {
	assert.Equal(t, "zsh", Interpreter("#!/usr/bin/env zsh"))
}

func TestParsesEnvPython3(t *testing.T) {
	assert.Equal(t, "python3", Interpreter("#!/usr/bin/env python3"))
}

func TestParsesEnvNode(t *testing.T) {
	assert.Equal(t, "node", Interpreter("#!/usr/bin/env node"))
}

func TestParsesEnvWithDashSFlag(t *testing.T) {
	assert.Equal(t, "python3", Interpreter("#!/usr/bin/env -S python3 -u"))
}

func TestReturnsEmptyForNonShebang(t *testing.T) {
	assert.Equal(t, "", Interpreter("# just a comment"))
}

func TestReturnsEmptyForEmptyString(t *testing.T) {
	assert.Equal(t, "", Interpreter(""))
}

func TestReturnsEmptyForBareShebang(t *testing.T) {
	assert.Equal(t, "", Interpreter("#!"))
}
