package claude

import (
	"encoding/json"
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// --- Test helpers ---

func kittyJSON(tabs ...kittyTab) string {
	osWindows := []kittyOSWindow{{Tabs: tabs}}
	data, _ := json.Marshal(osWindows)
	return string(data)
}

func makeTab(id int, windows ...kittyWindow) kittyTab {
	return kittyTab{ID: id, Windows: windows}
}

func makeWindow(id int, commands ...string) kittyWindow {
	var processes []kittyProcess
	for _, cmd := range commands {
		processes = append(processes, kittyProcess{Cmdline: []string{cmd}})
	}
	return kittyWindow{ID: id, ForegroundProcesses: processes}
}

// --- Window discovery ---

func TestFindsClaudeWindowInSameTab(t *testing.T) {
	jsonOutput := kittyJSON(
		makeTab(3, makeWindow(10, "zsh"), makeWindow(11, "claude")),
	)
	runner := func(name string, args ...string) (string, error) {
		return jsonOutput, nil
	}

	windowID, err := FindClaudeWindow(runner, 3)
	require.NoError(t, err)
	assert.Equal(t, 11, windowID)
}

func TestReturnsErrorWhenNoClaudeWindowInTab(t *testing.T) {
	jsonOutput := kittyJSON(
		makeTab(3, makeWindow(10, "zsh"), makeWindow(11, "nvim")),
	)
	runner := func(name string, args ...string) (string, error) {
		return jsonOutput, nil
	}

	_, err := FindClaudeWindow(runner, 3)
	assert.Error(t, err)
}

func TestIgnoresClaudeWindowsInOtherTabs(t *testing.T) {
	jsonOutput := kittyJSON(
		makeTab(3, makeWindow(10, "zsh")),
		makeTab(5, makeWindow(20, "claude")),
	)
	runner := func(name string, args ...string) (string, error) {
		return jsonOutput, nil
	}

	_, err := FindClaudeWindow(runner, 3)
	assert.Error(t, err)
}

// --- Review sending ---

func TestSendsCorrectTextToCorrectWindowID(t *testing.T) {
	var capturedName string
	var capturedArgs []string
	runner := func(name string, args ...string) (string, error) {
		capturedName = name
		capturedArgs = args
		return "", nil
	}

	err := SendReview(runner, 42, 3)
	require.NoError(t, err)
	assert.Equal(t, "kitty-window-send-text", capturedName)
	assert.Equal(t, []string{"42", "/git-file-watch-review\n"}, capturedArgs)
}

func TestReturnsErrorWhenNoCommentsExist(t *testing.T) {
	runner := func(name string, args ...string) (string, error) {
		t.Fatal("runner should not be called when no comments")
		return "", nil
	}

	err := SendReview(runner, 42, 0)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "no comments")
}

func TestReturnsErrorWhenSendFails(t *testing.T) {
	runner := func(name string, args ...string) (string, error) {
		return "", fmt.Errorf("connection refused")
	}

	err := SendReview(runner, 42, 3)
	assert.Error(t, err)
}
