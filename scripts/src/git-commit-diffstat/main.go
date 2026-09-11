package main

import (
	"fmt"
	"os"

	"github.com/pixelastic/oroshi/scripts/src/git-commit-diffstat/theme"
)

func main() {
	args := os.Args[1:]
	if len(args) != 3 {
		fmt.Fprintln(os.Stderr, "Usage: git-commit-diffstat <from> <to> <repo>")
		os.Exit(1)
	}

	oroshiRoot := os.Getenv("OROSHI_ROOT")
	if oroshiRoot == "" {
		fmt.Fprintln(os.Stderr, "OROSHI_ROOT not set")
		os.Exit(1)
	}

	_, err := theme.Load(oroshiRoot)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	fmt.Printf("git-commit-diffstat: from=%s to=%s repo=%s\n", args[0], args[1], args[2])
}
