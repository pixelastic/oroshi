package filetype

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

// --- Extension-based resolution ---

func TestResolvesGoExtensionToGoLanguageAndFiletypeKey(t *testing.T) {
	result := Resolve("main.go", "")
	assert.Equal(t, "go", result.Language)
	assert.Equal(t, "go", result.FiletypeKey)
}

func TestResolvesJsExtensionToRawExtension(t *testing.T) {
	result := Resolve("app.js", "")
	assert.Equal(t, "js", result.Language)
	assert.Equal(t, "js", result.FiletypeKey)
}

func TestResolvesBatsExtensionToRawExtension(t *testing.T) {
	result := Resolve("test.bats", "")
	assert.Equal(t, "bats", result.Language)
	assert.Equal(t, "bats", result.FiletypeKey)
}

func TestResolvesZshExtensionToRawExtension(t *testing.T) {
	result := Resolve("script.zsh", "")
	assert.Equal(t, "zsh", result.Language)
	assert.Equal(t, "zsh", result.FiletypeKey)
}

func TestResolvesPyExtensionToRawExtension(t *testing.T) {
	result := Resolve("main.py", "")
	assert.Equal(t, "py", result.Language)
	assert.Equal(t, "py", result.FiletypeKey)
}

// --- Path-pattern resolution ---

func TestResolvesZshAutoloadPathToBashAndZsh(t *testing.T) {
	result := Resolve("tools/term/zsh/config/functions/autoload/git/git-current-branch", "")
	assert.Equal(t, "bash", result.Language)
	assert.Equal(t, "zsh", result.FiletypeKey)
}

func TestDoesNotMatchPathPatternWhenFileHasExtension(t *testing.T) {
	result := Resolve("tools/term/zsh/config/functions/autoload/colors/colors.json", "")
	assert.Equal(t, "json", result.Language)
	assert.Equal(t, "json", result.FiletypeKey)
}

// --- Shebang-based resolution ---

func TestResolvesZshShebangToBashAndZsh(t *testing.T) {
	result := Resolve("scripts/onStartup", "#!/bin/zsh")
	assert.Equal(t, "bash", result.Language)
	assert.Equal(t, "zsh", result.FiletypeKey)
}

func TestResolvesBashShebangToBashAndSh(t *testing.T) {
	result := Resolve("scripts/build", "#!/usr/bin/env bash")
	assert.Equal(t, "bash", result.Language)
	assert.Equal(t, "sh", result.FiletypeKey)
}

func TestResolvesPython3ShebangToPythonAndPy(t *testing.T) {
	result := Resolve("scripts/deploy", "#!/usr/bin/env python3")
	assert.Equal(t, "python", result.Language)
	assert.Equal(t, "py", result.FiletypeKey)
}

func TestResolvesNodeShebangToJavascriptAndJs(t *testing.T) {
	result := Resolve("scripts/cli", "#!/usr/bin/env node")
	assert.Equal(t, "javascript", result.Language)
	assert.Equal(t, "js", result.FiletypeKey)
}

// --- Unknown / passthrough ---

func TestUnknownExtensionReturnsExtensionAsLanguageAndKey(t *testing.T) {
	result := Resolve("file.gleam", "")
	assert.Equal(t, "gleam", result.Language)
	assert.Equal(t, "gleam", result.FiletypeKey)
}

func TestNoExtensionNoMatchReturnsEmpty(t *testing.T) {
	result := Resolve("some/random/file", "")
	assert.Equal(t, "", result.Language)
	assert.Equal(t, "", result.FiletypeKey)
}

// --- Priority ---

func TestExtensionTakesPriorityOverShebang(t *testing.T) {
	result := Resolve("main.go", "#!/bin/zsh")
	assert.Equal(t, "go", result.Language)
	assert.Equal(t, "go", result.FiletypeKey)
}

func TestPathPatternTakesPriorityOverShebang(t *testing.T) {
	result := Resolve("tools/term/zsh/config/functions/autoload/git/git-foo", "#!/bin/bash")
	assert.Equal(t, "bash", result.Language)
	assert.Equal(t, "zsh", result.FiletypeKey)
}
