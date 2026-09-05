package git

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
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

// Head returns the current HEAD commit hash.
func Head(repoRoot string) (string, error) {
	cmd := exec.Command("git", "rev-parse", "HEAD")
	cmd.Dir = repoRoot
	output, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("resolving HEAD: %w", err)
	}
	return strings.TrimSpace(string(output)), nil
}

// SyntheticNewFileDiff generates a git-diff-formatted string for an untracked file,
// showing all lines as added.
func SyntheticNewFileDiff(path string, content string) string {
	if content == "" {
		return ""
	}
	lines := strings.Split(content, "\n")
	// Trim trailing empty lines from final newline
	for len(lines) > 0 && lines[len(lines)-1] == "" {
		lines = lines[:len(lines)-1]
	}
	if len(lines) == 0 {
		return ""
	}

	var b strings.Builder
	fmt.Fprintf(&b, "diff --git a/%s b/%s\n", path, path)
	b.WriteString("new file mode 100644\n")
	b.WriteString("--- /dev/null\n")
	fmt.Fprintf(&b, "+++ b/%s\n", path)
	fmt.Fprintf(&b, "@@ -0,0 +1,%d @@\n", len(lines))
	for _, line := range lines {
		b.WriteByte('+')
		b.WriteString(line)
		b.WriteByte('\n')
	}
	return b.String()
}

// UntrackedFiles returns relative paths of untracked files in the repo.
func UntrackedFiles(repoRoot string) ([]string, error) {
	cmd := exec.Command("git", "ls-files", "--others", "--exclude-standard")
	cmd.Dir = repoRoot
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("listing untracked files: %w", err)
	}
	raw := strings.TrimSpace(string(output))
	if raw == "" {
		return nil, nil
	}
	return strings.Split(raw, "\n"), nil
}

// Diff runs git diff in the given directory and returns the raw output,
// including synthetic diffs for untracked files.
func Diff(repoRoot string) (string, error) {
	cmd := exec.Command("git", "diff")
	cmd.Dir = repoRoot
	output, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("running git diff: %w", err)
	}

	result := string(output)

	untracked, err := UntrackedFiles(repoRoot)
	if err != nil {
		return result, nil
	}

	for _, path := range untracked {
		content, readErr := os.ReadFile(filepath.Join(repoRoot, path))
		if readErr != nil {
			continue
		}
		result += SyntheticNewFileDiff(path, string(content))
	}

	return result, nil
}
