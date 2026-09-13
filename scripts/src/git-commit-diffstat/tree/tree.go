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
	Name           string
	IsDir          bool
	Change         *diff.FileChange
	IsRenameSource bool
	Children       []*Node
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

		// For renames, insert source node at old path
		if change.Status == diff.Renamed && change.OldPath != "" {
			oldParts := strings.Split(change.OldPath, "/")
			insertFile(tree, dirMap, change.OldPath, &Node{
				Name:           oldParts[len(oldParts)-1],
				Change:         change,
				IsRenameSource: true,
			})
		}

		parts := strings.Split(change.Path, "/")
		insertFile(tree, dirMap, change.Path, &Node{
			Name:   parts[len(parts)-1],
			Change: change,
		})
	}

	sortNodes(tree.Roots)
	return tree
}

func insertFile(tree *Tree, dirMap map[string]*Node, filePath string, node *Node) {
	parts := strings.Split(filePath, "/")

	if len(parts) == 1 {
		tree.Roots = append(tree.Roots, node)
		return
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

	parent.Children = append(parent.Children, node)
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
	for _, node := range tree.Roots {
		renderRootNode(&builder, node, theme, barRenderer)
	}
	return builder.String()
}

func renderRootNode(builder *strings.Builder, node *Node, theme ThemeResolver, barRenderer BarRenderer) {
	if node.IsDir {
		dirStyle := lipgloss.NewStyle().Foreground(theme.Lipgloss("directory"))
		builder.WriteString(dirStyle.Render(node.Name))
		builder.WriteString("\n")
		for i, child := range node.Children {
			childIsLast := i == len(node.Children)-1
			renderNode(builder, child, "", childIsLast, theme, barRenderer)
		}
		return
	}

	// Root-level file
	if node.Change != nil {
		renderFileByStatus(builder, node, theme, barRenderer)
	} else {
		fileStyle := lipgloss.NewStyle().Foreground(theme.FiletypeColor(node.Name))
		builder.WriteString(fileStyle.Render(node.Name))
	}
	builder.WriteString("\n")
}

func renderNode(builder *strings.Builder, node *Node, prefix string, isLast bool, theme ThemeResolver, barRenderer BarRenderer) {
	grayStyle := lipgloss.NewStyle().Foreground(theme.Lipgloss("gray"))

	connector := "├─ "
	if isLast {
		connector = "└─ "
	}

	builder.WriteString(grayStyle.Render(prefix + connector))

	if node.IsDir {
		dirStyle := lipgloss.NewStyle().Foreground(theme.Lipgloss("directory"))
		builder.WriteString(dirStyle.Render(node.Name))
		builder.WriteString("\n")

		childPrefix := prefix + "│ "
		if isLast {
			childPrefix = prefix + "  "
		}
		for i, child := range node.Children {
			childIsLast := i == len(node.Children)-1
			renderNode(builder, child, childPrefix, childIsLast, theme, barRenderer)
		}
		return
	}

	// File node — status-aware rendering
	if node.Change != nil {
		renderFileByStatus(builder, node, theme, barRenderer)
	} else {
		fileStyle := lipgloss.NewStyle().Foreground(theme.FiletypeColor(node.Name))
		builder.WriteString(fileStyle.Render(node.Name))
	}
	builder.WriteString("\n")
}

func renderFileByStatus(builder *strings.Builder, node *Node, theme ThemeResolver, barRenderer BarRenderer) {
	switch {
	case node.IsRenameSource:
		renderRenameSource(builder, node, theme)
	case node.Change.Status == diff.Deleted:
		renderDeletedFile(builder, node, theme, barRenderer)
	case node.Change.Status == diff.Added:
		renderAddedFile(builder, node, theme, barRenderer)
	case node.Change.Status == diff.Renamed:
		renderRenameDestination(builder, node, theme, barRenderer)
	default:
		renderModifiedFile(builder, node, theme, barRenderer)
	}
}

func renderRenameSource(builder *strings.Builder, node *Node, theme ThemeResolver) {
	removedColor := theme.Lipgloss("git-removed")
	nameStyle := lipgloss.NewStyle().Foreground(removedColor).Strikethrough(true)
	builder.WriteString(nameStyle.Render(node.Name))
	arrowStyle := lipgloss.NewStyle().Foreground(removedColor)
	builder.WriteString(" " + arrowStyle.Render("→"))
}

func renderDeletedFile(builder *strings.Builder, node *Node, theme ThemeResolver, barRenderer BarRenderer) {
	removedColor := theme.Lipgloss("git-removed")
	nameStyle := lipgloss.NewStyle().Foreground(removedColor).Strikethrough(true)
	builder.WriteString(nameStyle.Render(node.Name))

	bar := barRenderer(*node.Change)
	if bar != "" {
		builder.WriteString(" " + bar)
	}

	symbolStyle := lipgloss.NewStyle().Foreground(removedColor)
	builder.WriteString(" " + symbolStyle.Render("✖"))
}

func renderAddedFile(builder *strings.Builder, node *Node, theme ThemeResolver, barRenderer BarRenderer) {
	fileStyle := lipgloss.NewStyle().Foreground(theme.FiletypeColor(node.Name))
	builder.WriteString(fileStyle.Render(node.Name))

	bar := barRenderer(*node.Change)
	if bar != "" {
		builder.WriteString(" " + bar)
	}

	addedColor := theme.Lipgloss("git-added")
	symbolStyle := lipgloss.NewStyle().Foreground(addedColor)
	builder.WriteString(" " + symbolStyle.Render("✚"))
}

func renderRenameDestination(builder *strings.Builder, node *Node, theme ThemeResolver, barRenderer BarRenderer) {
	fileStyle := lipgloss.NewStyle().Foreground(theme.FiletypeColor(node.Name))
	builder.WriteString(fileStyle.Render(node.Name))

	addedColor := theme.Lipgloss("git-added")
	arrowStyle := lipgloss.NewStyle().Foreground(addedColor)
	builder.WriteString(" " + arrowStyle.Render("←"))

	bar := barRenderer(*node.Change)
	if bar != "" {
		builder.WriteString(" " + bar)
	}
}

func renderModifiedFile(builder *strings.Builder, node *Node, theme ThemeResolver, barRenderer BarRenderer) {
	fileStyle := lipgloss.NewStyle().Foreground(theme.FiletypeColor(node.Name))
	builder.WriteString(fileStyle.Render(node.Name))

	bar := barRenderer(*node.Change)
	if bar != "" {
		builder.WriteString(" " + bar)
	}
}
