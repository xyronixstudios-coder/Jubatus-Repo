package editor

import (
	"os"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
)

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
		m.ready = true
		return m, nil

	case tea.KeyMsg:
		return m.handleKey(msg)

	case tea.MouseMsg:
		// Debug: uncomment to log every mouse event
		// m.statusMsg = fmt.Sprintf("btn=%d act=%d x=%d y=%d", msg.Button, msg.Action, msg.X, msg.Y)
		return m.handleMouse(msg)
	}
	return m, nil
}

func (m Model) handleKey(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	// If a prompt is open, route keys to prompt
	switch m.mode {
	case ModeSavePrompt:
		return m.handlePrompt(msg, "save")
	case ModeOpenPrompt:
		return m.handlePrompt(msg, "open")
	case ModeSearchPrompt:
		return m.handlePrompt(msg, "search")
	case ModeHelp:
		m.mode = ModeEdit
		return m, nil
	case ModeQuitConfirm:
		return m.handleQuitConfirm(msg)
	}

	// Normal editing mode
	switch msg.Type {
	case tea.KeyCtrlO:
		m.mode = ModeSavePrompt
		m.promptInput = m.buf.Path
		m.statusMsg = ""
		return m, nil

	case tea.KeyCtrlX:
		if m.buf.IsDirty {
			m.mode = ModeQuitConfirm
			m.statusMsg = "Save modified buffer? (y/n/^C)"
		} else {
			return m, tea.Quit
		}
		return m, nil

	case tea.KeyCtrlW:
		m.mode = ModeSearchPrompt
		m.promptInput = ""
		m.statusMsg = ""
		return m, nil

	case tea.KeyCtrlG:
		m.mode = ModeHelp
		return m, nil

	case tea.KeyCtrlR:
		m.mode = ModeOpenPrompt
		m.promptInput = ""
		m.statusMsg = ""
		return m, nil

	case tea.KeyCtrlK:
		if m.sel.Active {
			txt := m.SelectedText()
			if txt != "" {
				m.cutBuf = txt
				m.deleteSelection()
				m.statusMsg = "Cut " + itoa(len([]rune(txt))) + " chars"
				m.statusIsErr = false
				m.sel.Active = false
				return m, nil
			}
		}
		// No selection: cut entire line.
		m.cutBuf = m.CurrentLine() + "\n"
		m.buf.DeleteLine(m.cursorRow)
		if m.cursorRow >= m.buf.LineCount() {
			m.cursorRow = m.buf.LineCount() - 1
		}
		m.cursorCol = 0
		m.statusMsg = "Cut line"
		return m, nil

	case tea.KeyCtrlU:
		if m.cutBuf == "" {
			m.statusMsg = "Clipboard empty"
			return m, nil
		}
		if !strings.Contains(m.cutBuf, "\n") {
			// single-line paste at cursor
			m.doInsert(m.cutBuf)
			m.statusMsg = "Pasted"
			return m, nil
		}
		// multi-line paste: split by \n
		parts := strings.Split(m.cutBuf, "\n")
		if len(parts) > 0 && parts[len(parts)-1] == "" {
			parts = parts[:len(parts)-1]
		}
		if len(parts) == 0 {
			return m, nil
		}
		// Insert first part at cursor
		cur := m.CurrentLine()
		cr := []rune(cur)
		col := m.cursorCol
		if col > len(cr) {
			col = len(cr)
		}
		head := string(cr[:col])
		tail := string(cr[col:])
		m.buf.SetLine(m.cursorRow, head+parts[0])
		// Insert middle lines as new lines below
		for i := 1; i < len(parts); i++ {
			m.buf.InsertLine(m.cursorRow+i, parts[i])
		}
		// Append tail to last inserted line
		lastIdx := m.cursorRow + len(parts) - 1
		if tail != "" {
			m.buf.SetLine(lastIdx, m.buf.Line(lastIdx)+tail)
		}
		m.cursorRow = lastIdx
		m.cursorCol = len([]rune(m.buf.Line(lastIdx))) - len([]rune(tail))
		m.statusMsg = "Pasted " + itoa(len(parts)) + " lines"
		return m, nil

	case tea.KeyCtrlA:
		m.cursorCol = 0
		return m, nil

	case tea.KeyCtrlE:
		m.cursorCol = len([]rune(m.CurrentLine()))
		return m, nil

	case tea.KeyCtrlC:
		if m.sel.Active {
			txt := m.SelectedText()
			if txt != "" {
				copyToClipboard(txt)
				m.statusMsg = "Copied " + itoa(len([]rune(txt))) + " chars"
				m.statusIsErr = false
				m.sel.Active = false
				return m, nil
			}
		}
		m.statusMsg = m.positionMsg()
		return m, nil

	case tea.KeyCtrlV:
		step := m.textHeight()
		maxTop := m.buf.LineCount() - step
		if maxTop < 0 {
			maxTop = 0
		}
		m.topLine += step
		if m.topLine > maxTop {
			m.topLine = maxTop
		}
		m.cursorRow = m.topLine
		m.clampCol()
		return m, nil

	case tea.KeyCtrlY:
		step := m.textHeight()
		m.topLine -= step
		if m.topLine < 0 {
			m.topLine = 0
		}
		m.cursorRow = m.topLine
		m.clampCol()
		return m, nil

	case tea.KeyUp:
		if m.cursorRow > 0 {
			m.cursorRow--
			m.clampCol()
			m.followCursor()
		}
		return m, nil

	case tea.KeyDown:
		if m.cursorRow < m.buf.LineCount()-1 {
			m.cursorRow++
			m.clampCol()
			m.followCursor()
		}
		return m, nil

	case tea.KeyLeft:
		if m.cursorCol > 0 {
			m.cursorCol--
		} else if m.cursorRow > 0 {
			m.cursorRow--
			m.cursorCol = len([]rune(m.CurrentLine()))
		}
		return m, nil

	case tea.KeyRight:
		line := []rune(m.CurrentLine())
		if m.cursorCol < len(line) {
			m.cursorCol++
		} else if m.cursorRow < m.buf.LineCount()-1 {
			m.cursorRow++
			m.cursorCol = 0
		}
		return m, nil

	case tea.KeyHome:
		m.cursorCol = 0
		return m, nil

	case tea.KeyEnd:
		m.cursorCol = len([]rune(m.CurrentLine()))
		return m, nil

	case tea.KeyBackspace:
		m.doBackspace()
		return m, nil

	case tea.KeyDelete:
		m.doDelete()
		return m, nil

	case tea.KeyEnter:
		m.doSplitLine()
		return m, nil

	case tea.KeyTab:
		m.doInsert("\t")
		return m, nil

	case tea.KeyRunes:
		m.doInsert(string(msg.Runes))
		return m, nil

	case tea.KeySpace:
		m.doInsert(" ")
		return m, nil

	case tea.KeyEsc:
		m.statusMsg = ""
		return m, nil
	}

	return m, nil
}

// --- prompt handling ---

func (m Model) handlePrompt(msg tea.KeyMsg, kind string) (tea.Model, tea.Cmd) {
	switch msg.Type {
	case tea.KeyEsc:
		m.mode = ModeEdit
		m.promptInput = ""
		m.statusMsg = "Cancelled"
		return m, nil

	case tea.KeyEnter:
		text := m.promptInput
		m.promptInput = ""
		m.mode = ModeEdit
		switch kind {
		case "save":
			if text == "" {
				text = m.buf.Path
			}
			if text == "" {
				m.statusMsg = "No filename"
				return m, nil
			}
			if err := m.buf.Save(text); err != nil {
				m.statusMsg = "Error: " + err.Error()
				m.statusIsErr = true
			} else {
				m.statusMsg = "Saved: " + text
				m.statusIsErr = false
			}
		case "open":
			if text == "" {
				return m, nil
			}
			if err := m.buf.Load(text); err != nil {
				m.statusMsg = "Error: " + err.Error()
				m.statusIsErr = true
			} else {
				m.cursorRow = 0
				m.cursorCol = 0
				m.statusMsg = "Loaded: " + text
				m.statusIsErr = false
			}
		case "search":
			m.searchTerm = text
			m.searchHits = m.findHits(text)
			if len(m.searchHits) > 0 {
				m.jumpToNextHit()
				m.statusMsg = "Found in " + itoa(len(m.searchHits)) + " lines"
			} else {
				m.statusMsg = "Not found"
				m.statusIsErr = true
			}
		}
		return m, nil

	case tea.KeyBackspace:
		if len(m.promptInput) > 0 {
			m.promptInput = m.promptInput[:len(m.promptInput)-1]
		}
		return m, nil

	case tea.KeyRunes:
		m.promptInput += string(msg.Runes)
		return m, nil

	case tea.KeySpace:
		m.promptInput += " "
		return m, nil
	}
	return m, nil
}

func (m Model) handleQuitConfirm(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.Type {
	case tea.KeyCtrlC, tea.KeyEsc:
		m.mode = ModeEdit
		m.statusMsg = "Quit cancelled"
		return m, nil
	case tea.KeyRunes:
		switch strings.ToLower(string(msg.Runes)) {
		case "y":
			m.mode = ModeEdit
			if m.buf.Path == "" {
				m.mode = ModeSavePrompt
				return m, nil
			}
			_ = m.buf.Save("")
			return m, tea.Quit
		case "n":
			return m, tea.Quit
		}
	}
	return m, nil
}

func (m Model) handleMouse(msg tea.MouseMsg) (tea.Model, tea.Cmd) {
	// DEBUG (remove later)
	// m.statusMsg = fmt.Sprintf("btn=%d act=%d x=%d y=%d", msg.Button, msg.Action, msg.X, msg.Y)

	// Numeric wheel detection: bubbletea wheel buttons are 4/5 in SGR mode,
	// or 64/65 with modifiers. We accept any of them.
	b := int(msg.Button)
	isWheelUp := b == 4 || b == 64 || b == 68
	isWheelDown := b == 5 || b == 65 || b == 69

	if isWheelUp {
		if m.topLine > 0 {
			m.topLine--
		}
		return m, nil
	}
	if isWheelDown {
		maxTop := m.buf.LineCount() - m.textHeight()
		if maxTop < 0 {
			maxTop = 0
		}
		if m.topLine < maxTop {
			m.topLine++
		}
		return m, nil
	}

	// Other mouse events
	gutter := 5
	row := m.topLine + (msg.Y - 1)
	col := msg.X - gutter
	if col < 0 {
		col = 0
	}
	if row < 0 {
		row = 0
	}
	if row >= m.buf.LineCount() {
		row = m.buf.LineCount() - 1
	}
	line := []rune(m.buf.Line(row))
	if col > len(line) {
		col = len(line)
	}

	switch msg.Action {
	case tea.MouseActionPress:
		if msg.Button != tea.MouseButtonLeft {
			return m, nil
		}
		m.cursorRow = row
		m.cursorCol = col
		m.sel.Active = false
		m.dragging = true
		return m, nil

	case tea.MouseActionMotion:
		if !m.dragging {
			return m, nil
		}
		if !m.sel.Active {
			m.sel.Active = true
			m.sel.AnchorRow = m.cursorRow
			m.sel.AnchorCol = m.cursorCol
		}
		m.cursorRow = row
		m.cursorCol = col
		return m, nil

	case tea.MouseActionRelease:
		if msg.Button != tea.MouseButtonLeft {
			return m, nil
		}
		wasDragging := m.dragging
		m.dragging = false
		if wasDragging && m.sel.Active {
			txt := m.SelectedText()
			if txt != "" {
				copyToClipboard(txt)
				m.statusMsg = "Copied " + itoa(len([]rune(txt))) + " chars to clipboard"
				m.statusIsErr = false
				return m, nil
			}
			m.sel.Active = false
		}
		return m, nil
	}
	return m, nil
}

// base64Encode is a minimal base64 encoder for OSC 52 clipboard.
func base64Encode(s string) string {
	const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	data := []byte(s)
	var out []byte
	for i := 0; i < len(data); i += 3 {
		var b0, b1, b2 byte
		b0 = data[i]
		if i+1 < len(data) {
			b1 = data[i+1]
		}
		if i+2 < len(data) {
			b2 = data[i+2]
		}
		out = append(out, alphabet[b0>>2])
		out = append(out, alphabet[((b0&0x03)<<4)|(b1>>4)])
		if i+1 < len(data) {
			out = append(out, alphabet[((b1&0x0F)<<2)|(b2>>6)])
		} else {
			out = append(out, '=')
		}
		if i+2 < len(data) {
			out = append(out, alphabet[b2&0x3F])
		} else {
			out = append(out, '=')
		}
	}
	return string(out)
}

// --- low level edits ---

func (m *Model) doInsert(s string) {
	line := []rune(m.CurrentLine())
	col := m.cursorCol
	if col > len(line) {
		col = len(line)
	}
	newLine := string(line[:col]) + s + string(line[col:])
	m.buf.SetLine(m.cursorRow, newLine)
	m.cursorCol += len([]rune(s))
}

func (m *Model) doBackspace() {
	if m.cursorCol > 0 {
		line := []rune(m.CurrentLine())
		col := m.cursorCol
		newLine := string(line[:col-1]) + string(line[col:])
		m.buf.SetLine(m.cursorRow, newLine)
		m.cursorCol--
	} else if m.cursorRow > 0 {
		prevLen := len([]rune(m.buf.Line(m.cursorRow - 1)))
		merged := m.buf.Line(m.cursorRow-1) + m.CurrentLine()
		m.buf.SetLine(m.cursorRow-1, merged)
		m.buf.DeleteLine(m.cursorRow)
		m.cursorRow--
		m.cursorCol = prevLen
	}
}

func (m *Model) doDelete() {
	line := []rune(m.CurrentLine())
	col := m.cursorCol
	if col < len(line) {
		newLine := string(line[:col]) + string(line[col+1:])
		m.buf.SetLine(m.cursorRow, newLine)
	} else if m.cursorRow < m.buf.LineCount()-1 {
		merged := m.CurrentLine() + m.buf.Line(m.cursorRow+1)
		m.buf.SetLine(m.cursorRow, merged)
		m.buf.DeleteLine(m.cursorRow + 1)
	}
}

func (m *Model) doSplitLine() {
	line := []rune(m.CurrentLine())
	col := m.cursorCol
	if col > len(line) {
		col = len(line)
	}
	left := string(line[:col])
	right := string(line[col:])
	m.buf.SetLine(m.cursorRow, left)
	m.buf.InsertLine(m.cursorRow+1, right)
	m.cursorRow++
	m.cursorCol = 0
}

func (m *Model) clampCol() {
	line := []rune(m.CurrentLine())
	if m.cursorCol > len(line) {
		m.cursorCol = len(line)
	}
}

func (m Model) positionMsg() string {
	return "line " + itoa(m.cursorRow+1) + "/" + itoa(m.buf.LineCount()) +
		", col " + itoa(m.cursorCol+1)
}

func (m Model) textHeight() int {
	h := m.height - 4 // title(1) + status(1) + shortcuts(2)
	if h < 1 {
		h = 1
	}
	return h
}

// small int-to-string helper (avoid fmt import here)
func itoa(n int) string {
	if n == 0 {
		return "0"
	}
	neg := n < 0
	if neg {
		n = -n
	}
	var b [20]byte
	i := len(b)
	for n > 0 {
		i--
		b[i] = byte('0' + n%10)
		n /= 10
	}
	if neg {
		i--
		b[i] = '-'
	}
	return string(b[i:])
}

// findHits returns line numbers containing term.
func (m Model) findHits(term string) []int {
	var hits []int
	if term == "" {
		return hits
	}
	for i, line := range m.buf.Lines {
		if strings.Contains(line, term) {
			hits = append(hits, i)
		}
	}
	return hits
}

func (m *Model) jumpToNextHit() {
	for _, h := range m.searchHits {
		if h > m.cursorRow {
			m.cursorRow = h
			m.cursorCol = 0
			return
		}
	}
	if len(m.searchHits) > 0 {
		m.cursorRow = m.searchHits[0]
		m.cursorCol = 0
	}
}


// deleteSelection removes the currently selected text from the buffer
// and places the cursor at the start of the removed range.
func (m *Model) deleteSelection() {
	r1, c1, r2, c2, ok := m.SelectionRange()
	if !ok {
		return
	}
	if r1 == r2 {
		line := []rune(m.buf.Line(r1))
		if c1 > len(line) { c1 = len(line) }
		if c2 > len(line) { c2 = len(line) }
		if c1 > c2 { c1, c2 = c2, c1 }
		m.buf.SetLine(r1, string(line[:c1])+string(line[c2:]))
		m.cursorRow = r1
		m.cursorCol = c1
		return
	}
	// first line: keep [0:c1]
	line := []rune(m.buf.Line(r1))
	if c1 > len(line) { c1 = len(line) }
	head := string(line[:c1])
	// last line: keep [c2:]
	line = []rune(m.buf.Line(r2))
	if c2 > len(line) { c2 = len(line) }
	tail := string(line[c2:])
	// replace first line with head+tail, delete lines r1+1..r2
	m.buf.SetLine(r1, head+tail)
	for i := 0; i < r2-r1; i++ {
		m.buf.DeleteLine(r1 + 1)
	}
	m.cursorRow = r1
	m.cursorCol = c1
}

// followCursor adjusts topLine so the cursor stays visible.
func (m *Model) followCursor() {
	h := m.textHeight()
	if m.cursorRow < m.topLine {
		m.topLine = m.cursorRow
	}
	if m.cursorRow >= m.topLine+h {
		m.topLine = m.cursorRow - h + 1
	}
	maxTop := m.buf.LineCount() - h
	if maxTop < 0 {
		maxTop = 0
	}
	if m.topLine > maxTop {
		m.topLine = maxTop
	}
	if m.topLine < 0 {
		m.topLine = 0
	}
}

// copyToClipboard sends an OSC 52 sequence to the terminal so the
// selection ends up in the system clipboard. Supported by most modern
// terminals (GNOME Terminal, kitty, alacritty, iTerm2, wezterm).
// Inside tmux, set: set -g set-clipboard on
func copyToClipboard(text string) {
	enc := base64Encode(text)
	seq := "\x1b]52;c;" + enc + "\x07"
	os.Stdout.WriteString(seq)
}
