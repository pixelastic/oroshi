// Package gittest creates throw-away git repositories for tests, isolated from
// the repository the tests are run from.
package gittest

import (
	"os"
	"os/exec"
	"testing"

	"github.com/stretchr/testify/require"
)

// hookVariables are exported by git hooks (pre-commit does) and point every git
// command at the real repository, whatever the working directory is.
// Same list as the one cleared by tools/term/bats/config/helper.
var hookVariables = []string{"GIT_DIR", "GIT_INDEX_FILE", "GIT_OBJECT_DIRECTORY", "GIT_WORK_TREE"}

// Isolate unsets the variables exported by git hooks until the end of the test.
func Isolate(t *testing.T) {
	t.Helper()
	for _, name := range hookVariables {
		t.Setenv(name, "") // registers the restore of the original value
		require.NoError(t, os.Unsetenv(name))
	}
}

// NewRepo initializes an empty repository in a temporary directory and returns
// its path. Git commands run by the test cannot reach any other repository.
func NewRepo(t *testing.T) string {
	t.Helper()
	Isolate(t)
	repo := t.TempDir()
	for _, args := range [][]string{
		{"init", "--quiet", "--initial-branch=main"},
		{"config", "user.email", "test@example.com"},
		{"config", "user.name", "Test"},
		{"config", "commit.gpgsign", "false"},
	} {
		cmd := exec.Command("git", args...)
		cmd.Dir = repo
		output, err := cmd.CombinedOutput()
		require.NoError(t, err, string(output))
	}
	return repo
}
