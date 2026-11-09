package color

import (
	"fmt"
	"strings"
)

// ParseHexColor converts a hex color string to RGB components.
// Returns (0, 0, 0) for invalid input.
func ParseHexColor(hex string) (uint8, uint8, uint8) {
	hex = strings.TrimPrefix(hex, "#")
	if len(hex) != 6 {
		return 0, 0, 0
	}
	var r, g, b uint8
	_, _ = fmt.Sscanf(hex, "%02x%02x%02x", &r, &g, &b)
	return r, g, b
}
