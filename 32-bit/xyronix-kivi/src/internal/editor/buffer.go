package editor

import (
	"os"
	"strings"
)

// Buffer holds the text content as a slice of lines.
type Buffer struct {
	Lines   []string
	Path    string
	IsDirty bool
}

func NewBuffer() *Buffer {
	return &Buffer{Lines: []string{""}}
}

func (b *Buffer) Load(path string) error {
	data, err := os.ReadFile(path)
	if err != nil {
		return err
	}
	text := strings.ReplaceAll(string(data), "\r\n", "\n")
	lines := strings.Split(text, "\n")
	// Drop trailing empty line if file ends with newline
	if len(lines) > 0 && lines[len(lines)-1] == "" {
		lines = lines[:len(lines)-1]
	}
	if len(lines) == 0 {
		lines = []string{""}
	}
	b.Lines = lines
	b.Path = path
	b.IsDirty = false
	return nil
}

func (b *Buffer) Save(path string) error {
	if path != "" {
		b.Path = path
	}
	text := strings.Join(b.Lines, "\n") + "\n"
	if err := os.WriteFile(b.Path, []byte(text), 0644); err != nil {
		return err
	}
	b.IsDirty = false
	return nil
}

func (b *Buffer) LineCount() int { return len(b.Lines) }

func (b *Buffer) Line(n int) string {
	if n < 0 || n >= len(b.Lines) {
		return ""
	}
	return b.Lines[n]
}

func (b *Buffer) SetLine(n int, s string) {
	if n < 0 || n >= len(b.Lines) {
		return
	}
	b.Lines[n] = s
	b.IsDirty = true
}

func (b *Buffer) InsertLine(n int, s string) {
	if n < 0 {
		n = 0
	}
	if n > len(b.Lines) {
		n = len(b.Lines)
	}
	b.Lines = append(b.Lines[:n], append([]string{s}, b.Lines[n:]...)...)
	b.IsDirty = true
}

func (b *Buffer) DeleteLine(n int) {
	if n < 0 || n >= len(b.Lines) {
		return
	}
	b.Lines = append(b.Lines[:n], b.Lines[n+1:]...)
	if len(b.Lines) == 0 {
		b.Lines = []string{""}
	}
	b.IsDirty = true
}
