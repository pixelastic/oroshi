package git

import (
	"fmt"
	"os/exec"
	"strings"
)

// RepoRoot returns the absolute path of the git repository root.
func RepoRoot() (string, error) {
	cmd := exec.Command("git", "rev-parse", "--show-toplevel")
	output, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("finding git root: %w", err)
	}
	return strings.TrimSpace(string(output)), nil
}

// Diff runs git diff in the given directory and returns the raw output.
func Diff(repoRoot string) (string, error) {
	cmd := exec.Command("git", "diff")
	cmd.Dir = repoRoot
	output, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("running git diff: %w", err)
	}
	return string(output), nil
}
