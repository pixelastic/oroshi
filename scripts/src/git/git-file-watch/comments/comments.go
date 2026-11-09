package comments

import (
	"crypto/rand"
	"encoding/json"
	"errors"
	"fmt"
	"os"
)

// Comment represents a review annotation attached to a specific file line.
type Comment struct {
	ID          string `json:"id"`
	Filepath    string `json:"filepath"`
	LineNumber  int    `json:"lineNumber"`
	LineContent string `json:"lineContent"`
	Review      string `json:"review"`
	CommitHash  string `json:"commitHash"`
}

// Load reads a JSON array of comments from disk.
// Returns an empty slice if the file does not exist.
func Load(path string) ([]Comment, error) {
	data, err := os.ReadFile(path)
	if errors.Is(err, os.ErrNotExist) {
		return []Comment{}, nil
	}
	if err != nil {
		return nil, fmt.Errorf("reading comments: %w", err)
	}

	var comments []Comment
	if err := json.Unmarshal(data, &comments); err != nil {
		return nil, fmt.Errorf("parsing comments: %w", err)
	}

	return comments, nil
}

// Save writes a JSON array of comments to disk.
func Save(path string, comments []Comment) error {
	data, err := json.MarshalIndent(comments, "", "  ")
	if err != nil {
		return fmt.Errorf("marshaling comments: %w", err)
	}

	if err := os.WriteFile(path, data, 0o644); err != nil {
		return fmt.Errorf("writing comments: %w", err)
	}

	return nil
}

// Upsert adds a comment or updates an existing one matched by filepath+lineNumber.
// New comments get an 8-char hex id and the provided commitHash.
// Existing comments preserve their original id and commitHash.
func Upsert(comments []Comment, comment Comment, commitHash string) ([]Comment, error) {
	for i, existing := range comments {
		if existing.Filepath == comment.Filepath && existing.LineNumber == comment.LineNumber {
			comment.ID = existing.ID
			comment.CommitHash = existing.CommitHash
			comments[i] = comment
			return comments, nil
		}
	}
	id, err := generateID()
	if err != nil {
		return nil, fmt.Errorf("generating comment id: %w", err)
	}
	comment.ID = id
	comment.CommitHash = commitHash
	return append(comments, comment), nil
}

// generateID returns an 8-character random hex string using crypto/rand.
func generateID() (string, error) {
	buf := make([]byte, 4)
	if _, err := rand.Read(buf); err != nil {
		return "", fmt.Errorf("reading random bytes: %w", err)
	}
	return fmt.Sprintf("%x", buf), nil
}

// Delete removes a comment by filepath+lineNumber. No-op if not found.
func Delete(comments []Comment, filepath string, lineNumber int) []Comment {
	result := make([]Comment, 0, len(comments))
	for _, comment := range comments {
		if comment.Filepath == filepath && comment.LineNumber == lineNumber {
			continue
		}
		result = append(result, comment)
	}
	return result
}

// FindReview returns the review text for a matching filepath+lineNumber, or empty string.
func FindReview(comments []Comment, filepath string, lineNumber int) string {
	for _, comment := range comments {
		if comment.Filepath == filepath && comment.LineNumber == lineNumber {
			return comment.Review
		}
	}
	return ""
}

// Reattach updates comment line numbers after file content changes.
// For each comment, it searches for lineContent in the file's lines:
// - If found at a different line, update lineNumber
// - If not found but original lineNumber is valid, keep it
// - If not found and lineNumber is out of bounds, drop the comment
func Reattach(comments []Comment, fileLines map[string][]string) []Comment {
	result := make([]Comment, 0, len(comments))
	for _, comment := range comments {
		lines, ok := fileLines[comment.Filepath]
		if !ok {
			result = append(result, comment)
			continue
		}

		if foundLine := findContent(lines, comment.LineContent); foundLine > 0 {
			comment.LineNumber = foundLine
			result = append(result, comment)
			continue
		}

		if comment.LineNumber >= 1 && comment.LineNumber <= len(lines) {
			result = append(result, comment)
			continue
		}

		// Out of bounds and content not found — drop
	}
	return result
}

// ClearStale removes comments whose commitHash doesn't match the current HEAD.
// Comments with an empty commitHash (legacy) are also removed.
func ClearStale(comments []Comment, headHash string) []Comment {
	result := make([]Comment, 0, len(comments))
	for _, comment := range comments {
		if comment.CommitHash == headHash {
			result = append(result, comment)
		}
	}
	return result
}

// findContent returns the 1-based line number where content is found, or 0 if not found.
func findContent(lines []string, content string) int {
	for i, line := range lines {
		if line == content {
			return i + 1
		}
	}
	return 0
}
