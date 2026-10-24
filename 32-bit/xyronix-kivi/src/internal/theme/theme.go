// Package theme defines the color palette used by the editor.
// Kivi (kiwi) palette: green fruit, dark bark, warm accents.
package theme

import "github.com/charmbracelet/lipgloss"

const (
	// Version appears in the title bar.
	Version = "1.0.7"
	Name    = "kivi"

	// Author / studio info
	FullName    = "Xyronix Kivi Editor"
	Studio      = "Xyronix Studios"
	Author      = "Eren Mut"
	Description = "Modern, modeless terminal text editor"
)

// Kivi palette
var (
	// Kivi green is the star
	Kivi       = lipgloss.Color("#7A960F") // kivi flesh
	KiviLight  = lipgloss.Color("#A5C428") // highlight
	KiviDark   = lipgloss.Color("#4A5A08") // shadows

	// Backgrounds (bark / moss)
	Bg         = lipgloss.Color("#1A1F0E") // very dark moss
	BgLight    = lipgloss.Color("#2A3318") // selection bg

	// Foregrounds
	Fg         = lipgloss.Color("#E8F0D0") // warm off-white
	FgDim      = lipgloss.Color("#8A9668") // comments

	// Accents
	Brown      = lipgloss.Color("#8B6914") // kivi seeds / bark
	Orange     = lipgloss.Color("#D98E2E") // bright seed
	Red        = lipgloss.Color("#D94848") // error
	Cyan       = lipgloss.Color("#6FB89A") // links / cyan
	Pink       = lipgloss.Color("#C46A8E") // keywords
	Yellow     = lipgloss.Color("#D9C44A") // strings
	Purple     = lipgloss.Color("#9A7FCC") // numbers
	White      = lipgloss.Color("#FFFFFF")
)

// Styles
var (
	TitleStyle = lipgloss.NewStyle().
			Background(Kivi).
			Foreground(Bg).
			Bold(true).
			Padding(0, 1)

	// Highlight the version separately inside the title
	VersionStyle = lipgloss.NewStyle().
			Background(KiviDark).
			Foreground(KiviLight).
			Bold(true)

	StatusStyle = lipgloss.NewStyle().
			Background(Kivi).
			Foreground(Bg).
			Padding(0, 1)

	StatusErrStyle = lipgloss.NewStyle().
			Background(Red).
			Foreground(White).
			Bold(true).
			Padding(0, 1)

	ShortcutKeyStyle = lipgloss.NewStyle().
				Background(BgLight).
				Foreground(KiviLight).
				Bold(true)

	ShortcutDescStyle = lipgloss.NewStyle().
				Background(BgLight).
				Foreground(Fg)

	LineNumberStyle = lipgloss.NewStyle().
			Foreground(FgDim)

	LineNumberActiveStyle = lipgloss.NewStyle().
				Foreground(KiviLight).
				Bold(true)

	TildeStyle = lipgloss.NewStyle().
			Foreground(KiviDark)

	CursorStyle = lipgloss.NewStyle().
			Background(KiviLight).
			Foreground(Bg).
			Bold(true)

	// Text selection highlight
	SelectionStyle = lipgloss.NewStyle().
			Background(KiviDark).
			Foreground(White)

	SearchStyle = lipgloss.NewStyle().
			Background(Orange).
			Foreground(Bg).
			Bold(true)

	InfoStyle  = lipgloss.NewStyle().Foreground(KiviLight)
	ErrorStyle = lipgloss.NewStyle().Foreground(Red).Bold(true)

	// Syntax colors, tuned for the kivi palette
	KeywordStyle  = lipgloss.NewStyle().Foreground(Pink).Bold(true)
	TypeStyle     = lipgloss.NewStyle().Foreground(Cyan)
	StringStyle   = lipgloss.NewStyle().Foreground(Yellow)
	NumberStyle   = lipgloss.NewStyle().Foreground(Purple)
	CommentStyle  = lipgloss.NewStyle().Foreground(FgDim).Italic(true)
	FunctionStyle = lipgloss.NewStyle().Foreground(KiviLight)
	OperatorStyle = lipgloss.NewStyle().Foreground(Pink)
)
