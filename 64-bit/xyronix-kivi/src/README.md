# 🥝 Xyronix Kivi Editor

> A modern, modeless terminal text editor written in Go.
> By **Eren Mut** · [Xyronix Studios](https://github.com/xyronixstudios-coder)

[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html)
[![Go Version](https://img.shields.io/badge/Go-1.20%2B-00ADD8.svg)](https://go.dev/)

[🇹🇷 Türkçe](README.tr.md)

---

## 🥝 What is Kivi?

**Xyronix Kivi Editor** (short: **kivi**) is a lightweight, modeless
terminal text editor inspired by GNU nano but modernized for 2026.

Unlike **vi/vim**, kivi is **modeless**: every printable key inserts
text immediately, commands live only on `Ctrl` combinations. No `hjkl`,
no `:wq`, no `Esc`-to-return, no hidden modes.

Unlike **nano**, kivi has:

- A modern **kivi-green** color theme
- Real **mouse support**: click, drag-select, wheel scroll
- Auto-copy on selection release (OSC 52)
- **UTF-8** native, multi-language support
- Live **SIGWINCH** redraw on terminal resize
- Clean **Go** codebase (bubbletea + lipgloss)

---

## ✨ Features

| Category | Feature |
|----------|---------|
| **Editing** | Modeless, no hjkl, no insert mode |
| **Input** | Full UTF-8, CJK wide-char aware |
| **Mouse** | Click, drag-select, wheel, auto-copy |
| **Display** | Kivi-green theme, line numbers, tilde |
| **Resize** | Live redraw on SIGWINCH |
| **Keys** | Nano-compatible (^O, ^X, ^W, ^K, ^U, ^A, ^E) |
| **I/O** | Open, save, save-as, quit-with-prompt |
| **Search** | Forward search with wrap-around |

---

## 🚀 Installation

### Quick install

    git clone git@github.com:xyronixstudios-coder/Xyronix-Kivi-Editor.git
    cd Xyronix-Kivi-Editor
    ./install.sh

Supported: **Debian** (Debian, Ubuntu, Mint, Pop, Kali, Jubatus),
**Arch** (Manjaro, EndeavourOS), **Fedora** (RHEL, CentOS, Rocky),
**SUSE**, **Alpine**, **Void**, **Gentoo**, **NixOS**.

### Manual build

    make
    sudo make install

---

## 🎮 Usage

    kivi                    # empty buffer
    kivi notes.txt          # open a file
    kivi ~/config/app.conf  # path
    kivi --version          # version + author
    kivi --help             # help

---

## ⌨️ Keybindings

| Key | Action |
|-----|--------|
| `Ctrl+O` | Save |
| `Ctrl+X` | Exit (prompts if modified) |
| `Ctrl+R` | Open file |
| `Ctrl+W` | Search |
| `Alt+W`  | Search again |
| `Ctrl+K` | Cut (line or selection) |
| `Ctrl+U` | Paste cut buffer |
| `Ctrl+C` | Copy selection / cursor position |
| `Ctrl+A` | Home |
| `Ctrl+E` | End |
| `Ctrl+Y` | Page Up |
| `Ctrl+V` | Page Down |
| `Ctrl+G` | Help |

---

## 🖱️ Mouse support

| Action | Effect |
|--------|--------|
| **Left click** | Place cursor |
| **Left drag** | Select text |
| **Release** | Auto-copy selection (OSC 52) |
| **Wheel** | Scroll view |

---

## 📜 License

**GNU General Public License v2.0** — see [LICENSE](LICENSE).

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

---

## 🙏 Credits

- **Author:** Eren Mut
- **Studio:** [Xyronix Studios](https://github.com/xyronixstudios-coder)
- **Built with:** [bubbletea](https://github.com/charmbracelet/bubbletea),
  [lipgloss](https://github.com/charmbracelet/lipgloss)
- **Inspired by:** GNU nano, Pico

---

<p align="center">Made with 🥝 in Turkey</p>
