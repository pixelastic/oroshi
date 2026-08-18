package main

import (
	"fmt"
	"os"
)

func main() {
	for _, arg := range os.Args[1:] {
		if arg == "--help" || arg == "-h" {
			printUsage()
			return
		}
	}
	printUsage()
}

func printUsage() {
	fmt.Println("Usage: git-branch-push-pretty [options]")
	fmt.Println("  Pretty TUI wrapper around git push")
	os.Exit(0)
}
