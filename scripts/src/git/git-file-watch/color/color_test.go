package color

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestParseHexColor(t *testing.T) {
	tests := []struct {
		name string
		hex  string
		r    uint8
		g    uint8
		b    uint8
	}{
		{"with hash prefix", "#ff8800", 255, 136, 0},
		{"without hash prefix", "ff8800", 255, 136, 0},
		{"invalid length", "abc", 0, 0, 0},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r, g, b := ParseHexColor(tt.hex)
			assert.Equal(t, tt.r, r)
			assert.Equal(t, tt.g, g)
			assert.Equal(t, tt.b, b)
		})
	}
}
