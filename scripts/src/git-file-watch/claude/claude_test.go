package claude

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// --- Window discovery ---

func TestFindsClaudeWindowInTab(t *testing.T) {
	runner := func(name string, args ...string) (string, error) {
		return "11\n", nil
	}

	windowID, err := FindClaudeWindow(runner, 3)
	require.NoError(t, err)
	assert.Equal(t, 11, windowID)
}

func TestPassesTabIDToHelper(t *testing.T) {
	var capturedArgs []string
	runner := func(name string, args ...string) (string, error) {
		capturedArgs = args
		return "11\n", nil
	}

	_, _ = FindClaudeWindow(runner, 7)
	assert.Equal(t, []string{"kitty-window-filter-process", "claude", "--tab", "7"}, capturedArgs)
}

func TestReturnsErrorWhenHelperFails(t *testing.T) {
	runner := func(name string, args ...string) (string, error) {
		return "", fmt.Errorf("exit 1")
	}

	_, err := FindClaudeWindow(runner, 3)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "no Claude window found")
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
	assert.Equal(t, "bin-zsh", capturedName)
	assert.Equal(t, []string{"kitty-window-send-text", "42", "/git-file-watch-review\r"}, capturedArgs)
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
