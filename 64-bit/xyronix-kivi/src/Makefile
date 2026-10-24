# Xyronix Kivi Editor - Makefile
# Author: Eren Mut (Xyronix Studios)

BINARY  = kivi
PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
DATADIR ?= $(PREFIX)/share/kivi
DOCDIR  ?= $(PREFIX)/share/doc/kivi

.PHONY: all build run tidy clean install uninstall help

all: build

build:
	go build -o $(BINARY) .

run: build
	./$(BINARY)

tidy:
	go mod tidy

clean:
	rm -f $(BINARY)

install: build
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 $(BINARY) $(DESTDIR)$(BINDIR)/$(BINARY)
	install -d $(DESTDIR)$(DOCDIR)
	install -m 644 README.md $(DESTDIR)$(DOCDIR)/README.md 2>/dev/null || true

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/$(BINARY)
	rm -rf $(DESTDIR)$(DOCDIR)

help:
	@echo "Targets:"
	@echo "  build      Build $(BINARY) binary"
	@echo "  run        Build and run"
	@echo "  install    Install to $(BINDIR)"
	@echo "  uninstall  Remove installed files"
	@echo "  clean      Remove build artifacts"
	@echo "  tidy       Run go mod tidy"
