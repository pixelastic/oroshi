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
// showing all lines as added. Binary files (containing null bytes) get a
// "Binary files ... differ" marker instead of line content.
func SyntheticNewFileDiff(path string, content string) string {
	if content == "" {
		return ""
	}
	if strings.ContainsRune(content, 0) {
		return fmt.Sprintf("diff --git a/%s b/%s\nnew file mode 100644\nBinary files /dev/null and b/%s differ\n", path, path, path)
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

// Submodules returns relative paths of initialized submodules.
func Submodules(repoRoot string) []string {
	cmd := exec.Command("git", "submodule", "foreach", "--quiet", "echo $sm_path")
	cmd.Dir = repoRoot
	output, err := cmd.Output()
	if err != nil {
		return nil
	}
	raw := strings.TrimSpace(string(output))
	if raw == "" {
		return nil
	}
	return strings.Split(raw, "\n")
}

// Diff runs git diff in the given directory and returns the raw output,
// including synthetic diffs for untracked files and submodule diffs.
func Diff(repoRoot string) (string, error) {
	cmd := exec.Command("git", "diff", "--ignore-submodules=all")
	cmd.Dir = repoRoot
	output, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("running git diff: %w", err)
	}

	result := string(output)
	result += untrackedDiffs(repoRoot, "")

	for _, sub := range Submodules(repoRoot) {
		subRoot := filepath.Join(repoRoot, sub)

		subCmd := exec.Command("git", "diff")
		subCmd.Dir = subRoot
		subOutput, subErr := subCmd.Output()
		if subErr == nil && len(subOutput) > 0 {
			result += prefixDiffPaths(string(subOutput), sub)
		}

		result += untrackedDiffs(subRoot, sub)
	}

	return result, nil
}

func untrackedDiffs(directory, pathPrefix string) string {
	untracked, err := UntrackedFiles(directory)
	if err != nil {
		return ""
	}
	var result string
	for _, path := range untracked {
		content, readErr := os.ReadFile(filepath.Join(directory, path))
		if readErr != nil {
			continue
		}
		displayPath := path
		if pathPrefix != "" {
			displayPath = pathPrefix + "/" + path
		}
		result += SyntheticNewFileDiff(displayPath, string(content))
	}
	return result
}

// prefixDiffPaths prepends a submodule path to all file paths in raw diff output.
func prefixDiffPaths(raw, prefix string) string {
	if raw == "" {
		return ""
	}
	lines := strings.Split(strings.TrimSuffix(raw, "\n"), "\n")
	var b strings.Builder
	for _, line := range lines {
		switch {
		case strings.HasPrefix(line, "diff --git a/"):
			line = strings.Replace(line, " a/", " a/"+prefix+"/", 1)
			line = strings.Replace(line, " b/", " b/"+prefix+"/", 1)
		case strings.HasPrefix(line, "--- a/"):
			line = "--- a/" + prefix + "/" + line[6:]
		case strings.HasPrefix(line, "+++ b/"):
			line = "+++ b/" + prefix + "/" + line[6:]
		}
		b.WriteString(line)
		b.WriteByte('\n')
	}
	return b.String()
}
