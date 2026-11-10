package main

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/pixelastic/oroshi/scripts/src/git/git-branch-pull-pretty/recap"
	"github.com/pixelastic/oroshi/scripts/src/git/git-branch-pull-pretty/runner"
	"github.com/pixelastic/oroshi/scripts/src/git/git-branch-pull-pretty/tui"
	"github.com/pixelastic/oroshi/scripts/src/git/lib/theme"
)

func main() {
	args := os.Args[1:]
	for _, arg := range args {
		if arg == "--help" || arg == "-h" {
			printUsage()
			return
		}
	}

	oroshiRoot := os.Getenv("OROSHI_ROOT")
	if oroshiRoot == "" {
		fmt.Fprintln(os.Stderr, "OROSHI_ROOT not set")
		os.Exit(1)
	}

	cmdRunner := func(name string, args ...string) (string, error) {
		out, err := exec.Command(name, args...).Output()
		return string(out), err
	}
	zshRunner := func(function string, args ...string) (string, error) {
		return cmdRunner("bin-zsh", append([]string{function}, args...)...)
	}

	th, err := theme.Load(oroshiRoot, cmdRunner)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	currentBranch := zshOutput(zshRunner, "git-branch-current")
	startCommit := zshOutput(zshRunner, "git-commit-current")

	// Only another branch than the current one gets checked out
	switchedTo := ""
	if len(args) > 0 && args[0] != currentBranch {
		switchedTo = args[0]
	}

	model, err := runWithProgress(args)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	// Print what git said, because the recap would hide the failure reason
	if model.ExitCode() != 0 {
		fmt.Fprintln(os.Stderr, model.RawOutput())
		os.Exit(model.ExitCode())
	}

	events := model.Events()
	endCommit := zshOutput(zshRunner, "git-commit-current")
	if switchedTo == "" {
		events = runner.EnsureBranchUpdate(events, currentBranch, startCommit, endCommit)
	}
	input := recap.Input{
		Events:        events,
		Commits:       runner.CommitCounts(events, cmdRunner),
		CurrentBranch: currentBranch,
		SwitchedTo:    switchedTo,
	}
	if switchedTo == "" && endCommit != startCommit {
		input.Diffstat = strings.TrimRight(zshOutput(zshRunner, "git-commit-diffstat", startCommit), "\n")
	}
	fmt.Println(strings.Join(recap.Lines(input, themeStyler{theme: th}), "\n"))

	// The dependency update output goes below the recap
	for _, line := range runner.DependencyOutput(model.Output()) {
		fmt.Println(line)
	}
}

// runWithProgress pulls a branch (the current one by default) while displaying
// a progress bar.
func runWithProgress(args []string) (tui.Model, error) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel() // kill subprocess if TUI exits (Ctrl+C)

	command := append([]string{"bin-zsh", "git-branch-pull", "--progress"}, args...)
	program := tea.NewProgram(tui.New(7))
	go runner.Run(ctx, command, program.Send)

	finalModel, err := program.Run()
	if err != nil {
		return tui.Model{}, fmt.Errorf("running the progress bar: %w", err)
	}
	return finalModel.(tui.Model), nil
}

// zshOutput calls a zsh function and returns its trimmed stdout, or an empty
// string when the function fails.
func zshOutput(run runner.CommandRunner, function string, args ...string) string {
	out, err := run(function, args...)
	if err != nil {
		return ""
	}
	return strings.TrimSpace(out)
}

func printUsage() {
	fmt.Println("Usage: git-branch-pull-pretty [branch]")
	fmt.Println("  Pretty TUI wrapper around git-branch-pull")
	fmt.Println("  Pulls the current branch, or fetches and switches to [branch]")
}
