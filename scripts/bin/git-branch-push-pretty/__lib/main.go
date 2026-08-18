package main

import (
	"context"
	"fmt"
	"os"
	"os/exec"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/pixelastic/oroshi/scripts/bin/git-branch-push-pretty/__lib/runner"
	"github.com/pixelastic/oroshi/scripts/bin/git-branch-push-pretty/__lib/theme"
	"github.com/pixelastic/oroshi/scripts/bin/git-branch-push-pretty/__lib/tui"
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

	branch, _, pushArgs, err := runner.ParseArgs(args, cmdRunner)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	th, err := theme.Load(oroshiRoot, cmdRunner)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	branchColor, err := th.BranchColor(branch)
	if err != nil {
		branchColor = 7 // fallback to white
	}

	model := tui.New(branchColor)

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	p := tea.NewProgram(model)

	go func() {
		cmd := exec.CommandContext(ctx, "bin-zsh", append([]string{"git-branch-push"}, pushArgs...)...)
		stderr, err := cmd.StderrPipe()
		if err != nil {
			p.Send(tui.ErrorMsg{Raw: err.Error()})
			p.Send(tui.DoneMsg{ExitCode: 1})
			return
		}

		if err := cmd.Start(); err != nil {
			p.Send(tui.ErrorMsg{Raw: err.Error()})
			p.Send(tui.DoneMsg{ExitCode: 1})
			return
		}

		runner.StreamStderr(stderr, p.Send)

		exitCode := 0
		if err := cmd.Wait(); err != nil {
			if exitErr, ok := err.(*exec.ExitError); ok {
				exitCode = exitErr.ExitCode()
			} else {
				exitCode = 1
			}
		}
		p.Send(tui.DoneMsg{ExitCode: exitCode})
	}()

	finalModel, err := p.Run()
	cancel() // kill subprocess if TUI exits (Ctrl+C)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	m := finalModel.(tui.Model)
	for _, line := range m.Errors() {
		fmt.Fprintln(os.Stderr, line)
	}
	os.Exit(m.ExitCode())
}

func printUsage() {
	fmt.Println("Usage: git-branch-push-pretty [options]")
	fmt.Println("  Pretty TUI wrapper around git push")
	os.Exit(0)
}
