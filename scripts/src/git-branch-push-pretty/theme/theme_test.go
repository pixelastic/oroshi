package theme

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/charmbracelet/lipgloss"
)

// --- JSON loading ---

func TestColorReturnsANSIIndex(t *testing.T) {
	root := setupTestFiles(t)
	loaded, err := Load(root, nil)
	if err != nil {
		t.Fatalf("Load failed: %v", err)
	}
	ansi, err := loaded.Color("git-branch")
	if err != nil {
		t.Fatalf("Color failed: %v", err)
	}
	if ansi != 73 {
		t.Errorf("expected ANSI 73, got %d", ansi)
	}
}

func TestIconReturnsGlyph(t *testing.T) {
	root := setupTestFiles(t)
	loaded, err := Load(root, nil)
	if err != nil {
		t.Fatalf("Load failed: %v", err)
	}
	icon, err := loaded.Icon("git-branch-ahead")
	if err != nil {
		t.Fatalf("Icon failed: %v", err)
	}
	if icon != "UP" {
		t.Errorf("expected icon %q, got %q", "UP", icon)
	}
}

func TestColorReturnsErrorForUnknownKey(t *testing.T) {
	root := setupTestFiles(t)
	loaded, _ := Load(root, nil)
	_, err := loaded.Color("nonexistent")
	if err == nil {
		t.Error("expected error for unknown color key")
	}
}

func TestIconReturnsErrorForUnknownKey(t *testing.T) {
	root := setupTestFiles(t)
	loaded, _ := Load(root, nil)
	_, err := loaded.Icon("nonexistent")
	if err == nil {
		t.Error("expected error for unknown icon key")
	}
}

// --- Dynamic color resolution ---

func TestBranchColorCallsBinZsh(t *testing.T) {
	root := setupTestFiles(t)
	runner := func(name string, args ...string) (string, error) {
		if name != "bin-zsh" || args[0] != "git-branch-color" || args[1] != "main" {
			t.Errorf("unexpected command: %s %v", name, args)
		}
		return "73\n", nil
	}
	loaded, _ := Load(root, runner)
	ansi, err := loaded.BranchColor("main")
	if err != nil {
		t.Fatalf("BranchColor failed: %v", err)
	}
	if ansi != 73 {
		t.Errorf("expected 73, got %d", ansi)
	}
}

func TestRemoteColorCallsBinZsh(t *testing.T) {
	root := setupTestFiles(t)
	runner := func(name string, args ...string) (string, error) {
		if name != "bin-zsh" || args[0] != "git-remote-color" || args[1] != "origin" {
			t.Errorf("unexpected command: %s %v", name, args)
		}
		return "42\n", nil
	}
	loaded, _ := Load(root, runner)
	ansi, err := loaded.RemoteColor("origin")
	if err != nil {
		t.Fatalf("RemoteColor failed: %v", err)
	}
	if ansi != 42 {
		t.Errorf("expected 42, got %d", ansi)
	}
}

// --- Lipgloss conversion ---

func TestLipglossColorConvertsANSIIndex(t *testing.T) {
	got := ANSIToLipgloss(73)
	expected := lipgloss.Color("73")
	if got != expected {
		t.Errorf("expected lipgloss color %v, got %v", expected, got)
	}
}

// --- Helpers ---

func setupTestFiles(t *testing.T) string {
	t.Helper()
	root := t.TempDir()
	dir := filepath.Join(root, "tools", "term", "zsh", "config", "theming", "dist")
	if err := os.MkdirAll(dir, 0o755); err != nil {
		t.Fatal(err)
	}
	colorsJSON := `{"git-branch": {"ansi": 73, "hex": "#5fafaf"}, "git-remote": {"ansi": 42, "hex": "#00d787"}}`
	iconsJSON := `{"git-branch-ahead": "UP", "git-branch-behind": "DOWN"}`
	os.WriteFile(filepath.Join(dir, "colors.json"), []byte(colorsJSON), 0o644)
	os.WriteFile(filepath.Join(dir, "icons.json"), []byte(iconsJSON), 0o644)
	return root
}
