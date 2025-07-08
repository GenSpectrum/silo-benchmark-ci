
docs/help_text.1: docs/help_text.md
	pandoc --standalone --to man docs/help_text.md -o docs/help_text.1
