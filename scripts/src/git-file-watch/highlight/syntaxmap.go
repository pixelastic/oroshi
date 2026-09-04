package highlight

import (
	"encoding/json"
	"fmt"
	"os"
	"strings"
)

// SyntaxStyle holds the resolved styling for a tree-sitter capture.
type SyntaxStyle struct {
	ColorHex string
	Bold     bool
	Italic   bool
}

type syntaxEntry struct {
	Color  string `json:"color"`
	Bold   bool   `json:"bold"`
	Italic bool   `json:"italic"`
}

// SyntaxMap resolves tree-sitter capture names to styles using neovim-syntax.json.
type SyntaxMap struct {
	defaults  map[string]syntaxEntry
	languages map[string]map[string]syntaxEntry
	colors    ColorProvider
}

// LoadSyntaxMap loads neovim-syntax.json and returns a SyntaxMap that resolves
// capture names to hex colors via the given ColorProvider.
func LoadSyntaxMap(path string, colors ColorProvider) (*SyntaxMap, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("reading syntax map %s: %w", path, err)
	}

	var raw map[string]map[string]syntaxEntry
	if err := json.Unmarshal(data, &raw); err != nil {
		return nil, fmt.Errorf("parsing syntax map: %w", err)
	}

	syntaxMap := &SyntaxMap{
		defaults:  raw["default"],
		languages: make(map[string]map[string]syntaxEntry),
		colors:    colors,
	}
	if syntaxMap.defaults == nil {
		syntaxMap.defaults = make(map[string]syntaxEntry)
	}

	for lang, entries := range raw {
		if lang == "default" {
			continue
		}
		syntaxMap.languages[lang] = entries
	}

	return syntaxMap, nil
}

// Resolve returns the style for a capture name in the given language.
// Resolution order: language override → default → hierarchy fallback (strip last dot segment)
// → vim highlight group fallback (e.g. "comment" → "Comment").
func (m *SyntaxMap) Resolve(language string, captureName string) SyntaxStyle {
	name := captureName
	for {
		key := "@" + name
		if entry, ok := m.lookupLanguage(language, key); ok {
			return m.entryToStyle(entry)
		}
		if entry, ok := m.defaults[key]; ok {
			return m.entryToStyle(entry)
		}

		lastDot := strings.LastIndex(name, ".")
		if lastDot == -1 {
			break
		}
		name = name[:lastDot]
	}

	// Fallback: try the vim highlight group convention (title-cased, no @ prefix).
	// In Neovim, @comment links to Comment, @keyword to Keyword, etc.
	vimGroup := strings.ToUpper(name[:1]) + name[1:]
	if entry, ok := m.defaults[vimGroup]; ok {
		return m.entryToStyle(entry)
	}
	return SyntaxStyle{}
}

// RecognizedNames returns all unique capture names (without @ prefix) known to this map.
func (m *SyntaxMap) RecognizedNames() []string {
	seen := make(map[string]bool)
	for key := range m.defaults {
		if strings.HasPrefix(key, "@") {
			seen[key[1:]] = true
		}
	}
	for _, entries := range m.languages {
		for key := range entries {
			if strings.HasPrefix(key, "@") {
				seen[key[1:]] = true
			}
		}
	}

	names := make([]string, 0, len(seen))
	for name := range seen {
		names = append(names, name)
	}
	return names
}

func (m *SyntaxMap) lookupLanguage(language string, key string) (syntaxEntry, bool) {
	entries, ok := m.languages[language]
	if !ok {
		return syntaxEntry{}, false
	}
	entry, ok := entries[key]
	return entry, ok
}

func (m *SyntaxMap) entryToStyle(entry syntaxEntry) SyntaxStyle {
	return SyntaxStyle{
		ColorHex: m.colors.Hex(entry.Color),
		Bold:     entry.Bold,
		Italic:   entry.Italic,
	}
}
