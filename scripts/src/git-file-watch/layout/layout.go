package layout

import (
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/diff"
)

// Row is a display row in the layout output.
type Row interface {
	isRow()
}

// LineRow represents a file line with optional change marker.
// Distance is 0 for changed lines, and increases for context lines further away.
type LineRow struct {
	LineNumber int
	Content    string
	Marker     *diff.Marker
	Distance   int
}

func (LineRow) isRow() {}

// SeparatorRow represents an ellipsis between non-contiguous hunks.
type SeparatorRow struct{}

func (SeparatorRow) isRow() {}

// FileHeaderRow represents a file path header.
type FileHeaderRow struct {
	Path string
}

func (FileHeaderRow) isRow() {}

type lineRange struct {
	start int
	end   int
}

// Build expands marked lines with context, merges ranges, and emits rows.
func Build(fileDiff diff.FileDiff, markers map[int]diff.Marker, totalLines int) []Row {
	if len(markers) == 0 {
		return []Row{FileHeaderRow{Path: fileDiff.Path}}
	}

	ranges := expandRanges(markers, totalLines)
	merged := mergeRanges(ranges)
	return emitRows(fileDiff.Path, merged, markers)
}

func expandRanges(markers map[int]diff.Marker, totalLines int) []lineRange {
	ranges := make([]lineRange, 0, len(markers))
	for line := range markers {
		start := line - 3
		if start < 1 {
			start = 1
		}
		end := line + 3
		if end > totalLines {
			end = totalLines
		}
		ranges = append(ranges, lineRange{start: start, end: end})
	}
	sortRanges(ranges)
	return ranges
}

func sortRanges(ranges []lineRange) {
	for i := 1; i < len(ranges); i++ {
		for j := i; j > 0 && ranges[j].start < ranges[j-1].start; j-- {
			ranges[j], ranges[j-1] = ranges[j-1], ranges[j]
		}
	}
}

func mergeRanges(ranges []lineRange) []lineRange {
	if len(ranges) == 0 {
		return ranges
	}

	merged := []lineRange{ranges[0]}
	for _, r := range ranges[1:] {
		last := &merged[len(merged)-1]
		if r.start <= last.end+1 {
			if r.end > last.end {
				last.end = r.end
			}
			continue
		}
		merged = append(merged, r)
	}
	return merged
}

func emitRows(path string, ranges []lineRange, markers map[int]diff.Marker) []Row {
	rows := []Row{FileHeaderRow{Path: path}}

	for i, r := range ranges {
		if i > 0 {
			rows = append(rows, SeparatorRow{})
		}
		for line := r.start; line <= r.end; line++ {
			row := LineRow{LineNumber: line}
			if marker, ok := markers[line]; ok {
				m := marker
				row.Marker = &m
			} else {
				row.Distance = distanceToNearest(line, markers)
			}
			rows = append(rows, row)
		}
	}

	return rows
}

func distanceToNearest(line int, markers map[int]diff.Marker) int {
	best := 999
	for markedLine := range markers {
		d := line - markedLine
		if d < 0 {
			d = -d
		}
		if d < best {
			best = d
		}
	}
	return best
}
