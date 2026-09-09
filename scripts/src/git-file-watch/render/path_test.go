package render

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

// --- SimplifyPath ---

func TestSimplifyPathTruncatesLongPath(t *testing.T) {
	result := SimplifyPath("a/b/c/d/e", 4)
	assert.Equal(t, "a/…/d/e", result)
}

func TestSimplifyPathKeepsPathAtMaxDisplay(t *testing.T) {
	result := SimplifyPath("a/b/c/d", 4)
	assert.Equal(t, "a/b/c/d", result)
}

func TestSimplifyPathKeepsShortPath(t *testing.T) {
	result := SimplifyPath("a/b", 4)
	assert.Equal(t, "a/b", result)
}

func TestSimplifyPathKeepsSingleSegment(t *testing.T) {
	result := SimplifyPath("a", 4)
	assert.Equal(t, "a", result)
}

func TestSimplifyPathMaxDisplay5(t *testing.T) {
	result := SimplifyPath("a/b/c/d/e/f", 5)
	assert.Equal(t, "a/b/…/e/f", result)
}

func TestSimplifyPathMaxDisplay6(t *testing.T) {
	result := SimplifyPath("a/b/c/d/e/f/g", 6)
	assert.Equal(t, "a/b/…/e/f/g", result)
}

func TestSimplifyPathClampsBelow4(t *testing.T) {
	result := SimplifyPath("a/b/c/d/e", 3)
	assert.Equal(t, "a/…/d/e", result)
}

func TestSimplifyPathClampsZero(t *testing.T) {
	result := SimplifyPath("a/b/c/d/e", 0)
	assert.Equal(t, "a/…/d/e", result)
}

// --- FitPath ---

func TestFitPathReturnsFullPathWhenItFits(t *testing.T) {
	result := FitPath("src/main.go", 40)
	assert.Equal(t, "src/main.go", result)
}

func TestFitPathReturnsFullPathWhenExactWidth(t *testing.T) {
	result := FitPath("src/main.go", len("src/main.go"))
	assert.Equal(t, "src/main.go", result)
}

func TestFitPathSimplifiesOneLevel(t *testing.T) {
	// "src/pkg/deep/nested/file.go" = 27 chars
	// With 5 segments, simplify to 4: "src/…/nested/file.go" = 20 chars
	result := FitPath("src/pkg/deep/nested/file.go", 25)
	assert.Equal(t, "src/…/nested/file.go", result)
}

func TestFitPathSimplifiesProgressively(t *testing.T) {
	// "a/b/c/d/e/f/g.go" = 6 dirs + file = 7 segments
	// maxDisplay=6: "a/b/…/e/f/g.go" = 14 chars
	// maxDisplay=5: "a/b/…/f/g.go" = 12 chars
	// maxDisplay=4: "a/…/f/g.go" = 10 chars
	result := FitPath("a/b/c/d/e/f/g.go", 12)
	assert.Equal(t, "a/b/…/f/g.go", result)
}

func TestFitPathStopsAtMinimumSimplification(t *testing.T) {
	// Even if maxDisplay=4 doesn't fit, return it (best effort)
	result := FitPath("a/b/c/d/e/f/g.go", 5)
	assert.Equal(t, "a/…/f/g.go", result)
}

func TestFitPathNoSimplifyForTwoSegments(t *testing.T) {
	// 2 segments can't be simplified (below 4-segment minimum)
	result := FitPath("very-long-directory-name/file.go", 10)
	assert.Equal(t, "very-long-directory-name/file.go", result)
}

func TestFitPathZeroWidthReturnsFullPath(t *testing.T) {
	result := FitPath("src/main.go", 0)
	assert.Equal(t, "src/main.go", result)
}
