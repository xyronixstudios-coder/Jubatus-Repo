package editor

import (
	tea "github.com/charmbracelet/bubbletea"
)

type Mode int

const (
	ModeEdit Mode = iota
	ModeSavePrompt
	ModeOpenPrompt
	ModeSearchPrompt
	ModeSearchNext
	ModeHelp
	ModeQuitConfirm
)

// Selection represents a text range from anchor to cursor.
// Both endpoints are (row, col) with col in runes.
type Selection struct {
	Active    bool
	AnchorRow int
	AnchorCol int
}

type Model struct {
	buf *Buffer

	cursorRow int
	cursorCol int

	width  int
	height int

	mode        Mode
	promptInput string
	statusMsg   string
	statusIsErr bool

	searchTerm string
	searchHits []int

	cutBuf string

	// Mouse drag selection
	sel      Selection
	dragging bool

	// Scroll offset (kept in sync with cursor visibility)
	topLine int

	ready bool
}

func New() Model {
	return Model{
		buf:  NewBuffer(),
		mode: ModeEdit,
	}
}

func (m Model) WithFile(path string) Model {
	if err := m.buf.Load(path); err != nil {
		m.statusMsg = "New file: " + path
		m.buf.Path = path
	} else {
		m.statusMsg = "Loaded: " + path
	}
	return m
}

func (m Model) Init() tea.Cmd { return nil }

func (m Model) CurrentLine() string { return m.buf.Line(m.cursorRow) }

func (m Model) Buf() *Buffer { return m.buf }

// Selection helpers -------------------------------------------------

// ClearSelection drops any active selection.
func (m *Model) ClearSelection() {
	m.sel.Active = false
}

// StartSelection anchors a selection at the cursor.
func (m *Model) StartSelection() {
	m.sel.Active = true
	m.sel.AnchorRow = m.cursorRow
	m.sel.AnchorCol = m.cursorCol
}

// SelectionRange normalizes the selection: returns start/end ordered.
// Returns ok=false if no selection is active.
func (m Model) SelectionRange() (r1, c1, r2, c2 int, ok bool) {
	if !m.sel.Active {
		return 0, 0, 0, 0, false
	}
	r1, c1 = m.sel.AnchorRow, m.sel.AnchorCol
	r2, c2 = m.cursorRow, m.cursorCol
	if r1 > r2 || (r1 == r2 && c1 > c2) {
		r1, r2 = r2, r1
		c1, c2 = c2, c1
	}
	return r1, c1, r2, c2, true
}

// SelectedText returns the text currently selected (with \n separators).
func (m Model) SelectedText() string {
	r1, c1, r2, c2, ok := m.SelectionRange()
	if !ok {
		return ""
	}
	if r1 == r2 {
		line := []rune(m.buf.Line(r1))
		if c1 > len(line) { c1 = len(line) }
		if c2 > len(line) { c2 = len(line) }
		if c1 > c2 { c1, c2 = c2, c1 }
		return string(line[c1:c2])
	}
	out := ""
	// first line
	line := []rune(m.buf.Line(r1))
	if c1 > len(line) { c1 = len(line) }
	out += string(line[c1:])
	out += "\n"
	// middle lines
	for r := r1 + 1; r < r2; r++ {
		out += m.buf.Line(r)
		out += "\n"
	}
	// last line
	line = []rune(m.buf.Line(r2))
	if c2 > len(line) { c2 = len(line) }
	out += string(line[:c2])
	return out
}
