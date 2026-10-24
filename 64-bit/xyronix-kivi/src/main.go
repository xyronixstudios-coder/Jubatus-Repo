// Command kivi is a modern, modeless terminal text editor.
//
// Full name:  Xyronix Kivi Editor
// Studio:     Xyronix Studios
// Author:     Eren Mut
package main

import (
	"fmt"
	"os"

	tea "github.com/charmbracelet/bubbletea"
	"xyronix-kivi-editor/internal/editor"
	"xyronix-kivi-editor/internal/theme"
)

const usageText = `kivi - ` + "`" + `Xyronix Kivi Editor` + "`" + `

Usage:
    kivi [file]

Options:
    -h, --help       Show this help
    -v, --version    Show version and author info

Keybindings:
    ^O  Save         ^X  Exit         ^G  Help
    ^R  Open         ^W  Search       ^K  Cut
    ^U  Paste        ^C  Copy         ^A  Home
    ^E  End          ^Y  Page Up      ^V  Page Down

Mouse:
    Click to place cursor, drag to select.
    Wheel to scroll. Release auto-copies selection.

`

func printVersion() {
	fmt.Printf("kivi %s\n", theme.Version)
	fmt.Printf("%s\n", theme.FullName)
	fmt.Printf("By %s - %s\n", theme.Author, theme.Studio)
}

func main() {
	if len(os.Args) > 1 {
		switch os.Args[1] {
		case "-v", "--version":
			printVersion()
			return
		case "-h", "--help":
			fmt.Print(usageText)
			return
		}
	}

	if len(os.Args) > 2 {
		fmt.Fprintln(os.Stderr, "usage: kivi [file]")
		os.Exit(1)
	}

	m := editor.New()
	if len(os.Args) == 2 {
		m = m.WithFile(os.Args[1])
	}

	p := tea.NewProgram(
		m,
		tea.WithAltScreen(),
		tea.WithMouseCellMotion(),
	)

	if _, err := p.Run(); err != nil {
		fmt.Fprintln(os.Stderr, "kivi:", err)
		os.Exit(1)
	}
}
