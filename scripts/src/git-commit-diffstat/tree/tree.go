package tree

import (
	"sort"
	"strings"

	"github.com/charmbracelet/lipgloss"
	"github.com/pixelastic/oroshi/scripts/src/git-commit-diffstat/diff"
)

// ThemeResolver provides colors for rendering.
type ThemeResolver interface {
	FiletypeColor(filename string) lipgloss.Color
	Lipgloss(name string) lipgloss.Color
}

// BarRenderer returns a styled magnitude bar for a file change.
type BarRenderer func(change diff.FileChange) string

// Node represents a file or directory in the tree.
type Node struct {
	Name     string
	IsDir    bool
	Change   *diff.FileChange
	Children []*Node
}

// Tree is the root of a file change tree.
type Tree struct {
	Roots []*Node
}

// Build constructs a tree from file changes.
func Build(changes []diff.FileChange) *Tree {
	tree := &Tree{}
	dirMap := map[string]*Node{}

	for i := range changes {
		change := &changes[i]
		parts := strings.Split(change.Path, "/")

		if len(parts) == 1 {
			tree.Roots = append(tree.Roots, &Node{
				Name:   parts[0],
				Change: change,
			})
			continue
		}

		// Walk directory path, creating intermediate nodes
		parent := (*Node)(nil)
		for depth := 0; depth < len(parts)-1; depth++ {
			key := strings.Join(parts[:depth+1], "/")
			dirNode, exists := dirMap[key]
			if !exists {
				dirNode = &Node{Name: parts[depth], IsDir: true}
				dirMap[key] = dirNode
				if parent == nil {
					tree.Roots = append(tree.Roots, dirNode)
				} else {
					parent.Children = append(parent.Children, dirNode)
				}
			}
			parent = dirNode
		}

		// Add the file as a leaf
		fileName := parts[len(parts)-1]
		parent.Children = append(parent.Children, &Node{
			Name:   fileName,
			Change: change,
		})
	}

	sortNodes(tree.Roots)
	return tree
}

// sortNodes sorts nodes: directories first, then files, alphabetical within each group.
func sortNodes(nodes []*Node) {
	sort.Slice(nodes, func(i, j int) bool {
		if nodes[i].IsDir != nodes[j].IsDir {
			return nodes[i].IsDir
		}
		return nodes[i].Name < nodes[j].Name
	})
	for _, node := range nodes {
		if node.IsDir {
			sortNodes(node.Children)
		}
	}
}

// Render returns a styled string representing the tree.
func Render(tree *Tree, theme ThemeResolver, barRenderer BarRenderer) string {
	var builder strings.Builder
	for i, node := range tree.Roots {
		isLast := i == len(tree.Roots)-1
		renderNode(&builder, node, "", isLast, theme, barRenderer)
	}
	return builder.String()
}

func renderNode(builder *strings.Builder, node *Node, prefix string, isLast bool, theme ThemeResolver, barRenderer BarRenderer) {
	grayStyle := lipgloss.NewStyle().Foreground(theme.Lipgloss("gray"))

	connector := "├── "
	if isLast {
		connector = "└── "
	}

	builder.WriteString(grayStyle.Render(prefix + connector))

	if node.IsDir {
		dirStyle := lipgloss.NewStyle().Foreground(theme.Lipgloss("directory"))
		builder.WriteString(dirStyle.Render(node.Name))
		builder.WriteString("\n")

		childPrefix := prefix + "│   "
		if isLast {
			childPrefix = prefix + "    "
		}
		for i, child := range node.Children {
			childIsLast := i == len(node.Children)-1
			renderNode(builder, child, childPrefix, childIsLast, theme, barRenderer)
		}
		return
	}

	// File node
	fileStyle := lipgloss.NewStyle().Foreground(theme.FiletypeColor(node.Name))
	builder.WriteString(fileStyle.Render(node.Name))

	if node.Change != nil {
		bar := barRenderer(*node.Change)
		if bar != "" {
			builder.WriteString(" " + bar)
		}
	}
	builder.WriteString("\n")
}
