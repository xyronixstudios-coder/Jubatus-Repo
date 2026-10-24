package editor

import (
	"strings"

	"github.com/charmbracelet/lipgloss"
	"xyronix-kivi-editor/internal/theme"
)

func (m Model) View() string {
	if !m.ready {
		return "Loading..."
	}

	switch m.mode {
	case ModeHelp:
		return m.viewHelp()
	}

	var b strings.Builder

	// Title bar
	b.WriteString(m.viewTitle())
	b.WriteString("\n")

	// Text area
	b.WriteString(m.viewText())
	b.WriteString("\n")

	// Status bar
	b.WriteString(m.viewStatus())
	b.WriteString("\n")

	// Shortcuts (2 lines)
	b.WriteString(m.viewShortcuts())

	return b.String()
}

func (m Model) viewTitle() string {
	name := m.buf.Path
	if name == "" {
		name = "[No Name]"
	}
	mark := ""
	if m.buf.IsDirty {
		mark = " *"
	}

	left := "  " + theme.Name + " " + theme.Version + "   " + name + mark

	gap := m.width - lipgloss.Width(left)
	if gap < 0 {
		gap = 0
	}
	text := left + strings.Repeat(" ", gap)

	return theme.TitleStyle.Width(m.width).Render(text)
}

func (m Model) viewText() string {
	height := m.textHeight()
	var b strings.Builder

	// Clamp topLine so it stays valid.
	top := m.topLine
	if top < 0 {
		top = 0
	}
	maxTop := m.buf.LineCount() - height
	if maxTop < 0 {
		maxTop = 0
	}
	if top > maxTop {
		top = maxTop
	}

	for i := 0; i < height; i++ {
		lineIdx := top + i
		if lineIdx >= m.buf.LineCount() {
			numStyle := theme.LineNumberStyle
			b.WriteString(numStyle.Render("     "))
			b.WriteString(theme.TildeStyle.Render("~"))
			b.WriteString("\n")
			continue
		}

		numStyle := theme.LineNumberStyle
		if lineIdx == m.cursorRow {
			numStyle = theme.LineNumberActiveStyle
		}
		num := padLeft(itoa(lineIdx+1), 3) + "  "
		b.WriteString(numStyle.Render(num))

		line := m.buf.Line(lineIdx)
		b.WriteString(m.renderLine(lineIdx, line))
		b.WriteString("\n")
	}

	out := b.String()
	if strings.HasSuffix(out, "\n") {
		out = out[:len(out)-1]
	}
	return out
}

// renderLine renders one line, applying selection highlight to any
// range covered by the current selection, and a block cursor cell
// if this is the cursor line.
func (m Model) renderLine(lineIdx int, line string) string {
	runes := []rune(line)

	// Selection slice on this line.
	selStart, selEnd := -1, -1
	if r1, c1, r2, c2, ok := m.SelectionRange(); ok {
		if lineIdx >= r1 && lineIdx <= r2 {
			if lineIdx == r1 {
				selStart = c1
			} else {
				selStart = 0
			}
			if lineIdx == r2 {
				selEnd = c2
			} else {
				selEnd = len(runes)
			}
			if selStart > len(runes) {
				selStart = len(runes)
			}
			if selEnd > len(runes) {
				selEnd = len(runes)
			}
		}
	}

	curCol := -1
	if lineIdx == m.cursorRow {
		curCol = m.cursorCol
		if curCol > len(runes) {
			curCol = len(runes)
		}
	}

	var b strings.Builder
	for i := 0; i <= len(runes); i++ {
		if i == len(runes) {
			if i == curCol {
				b.WriteString(theme.CursorStyle.Render(" "))
			}
			break
		}
		ch := string(runes[i])
		inSel := selStart >= 0 && i >= selStart && i < selEnd
		switch {
		case i == curCol && !inSel:
			b.WriteString(theme.CursorStyle.Render(ch))
		case i == curCol && inSel:
			// cursor inside selection: still show block
			b.WriteString(theme.CursorStyle.Render(ch))
		case inSel:
			b.WriteString(theme.SelectionStyle.Render(ch))
		default:
			b.WriteString(ch)
		}
	}
	return b.String()
}

func (m Model) viewStatus() string {
	var text string
	var style lipgloss.Style

	if m.mode == ModeSavePrompt {
		text = " File Name to Write: " + m.promptInput
		style = theme.StatusStyle
	} else if m.mode == ModeOpenPrompt {
		text = " File to Open: " + m.promptInput
		style = theme.StatusStyle
	} else if m.mode == ModeSearchPrompt {
		text = " Search: " + m.promptInput
		style = theme.StatusStyle
	} else if m.statusMsg != "" {
		text = " " + m.statusMsg
		if m.statusIsErr {
			style = theme.StatusStyle.Background(theme.Red)
		} else {
			style = theme.StatusStyle
		}
	} else {
		flag := "Read"
		if m.buf.IsDirty {
			flag = "Modified"
		}
		text = " " + flag + " | line " +
			itoa(m.cursorRow+1) + "/" + itoa(m.buf.LineCount()) +
			", col " + itoa(m.cursorCol+1) + " "
		style = theme.StatusStyle
	}

	return style.Width(m.width).Render(text)
}

func (m Model) viewShortcuts() string {
	type sc struct{ key, desc string }
	line1 := []sc{
		{"^G", "Help"}, {"^O", "Write Out"}, {"^W", "Where Is"},
		{"^K", "Cut Text"}, {"^J", "Justify"},
	}
	line2 := []sc{
		{"^X", "Exit"}, {"^R", "Read File"}, {"^U", "Paste Text"},
		{"^C", "Cur Pos"}, {"^A", "Home"},
	}

	render := func(items []sc) string {
		var b strings.Builder
		for i, s := range items {
			if i > 0 {
				b.WriteString("  ")
			}
			b.WriteString(theme.ShortcutKeyStyle.Render(" " + s.key + " "))
			b.WriteString(theme.ShortcutDescStyle.Render(" " + s.desc))
		}
		out := b.String()
		w := lipgloss.Width(out)
		if w < m.width {
			out += strings.Repeat(" ", m.width-w)
		}
		return out
	}

	return render(line1) + "\n" + render(line2)
}

func (m Model) viewHelp() string {
	lines := []string{
		"  kivi - Help",
		"",
		"  ^G   Show this help",
		"  ^O   Write file (save)",
		"  ^X   Exit (asks if modified)",
		"  ^R   Read file (open)",
		"  ^W   Search",
		"  ^K   Cut current line",
		"  ^U   Paste cut line",
		"  ^A   Start of line",
		"  ^E   End of line",
		"  ^Y   Page up",
		"  ^V   Page down",
		"  ^C   Cursor position",
		"",
		"  Arrow keys move. Mouse click moves cursor.",
		"  Any printable key inserts text.",
		"  Modeless: no hjkl, no ESC-mode.",
		"",
		"  Press any key to return.",
	}
	return strings.Join(lines, "\n")
}

func padLeft(s string, n int) string {
	if len(s) >= n {
		return s
	}
	return strings.Repeat(" ", n-len(s)) + s
}
