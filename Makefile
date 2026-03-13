DOTCLAUDE_DIR := $(abspath .claude)
TARGET_DIR := $(HOME)/.claude

TARGETS := CLAUDE.md skills agents

.PHONY: install uninstall

install:
	@for target in $(TARGETS); do \
		dest="$(TARGET_DIR)/$$target"; \
		if [ -e "$$dest" ] && [ ! -L "$$dest" ]; then \
			echo "Backing up $$dest to $$dest.bak"; \
			mv "$$dest" "$$dest.bak"; \
		elif [ -L "$$dest" ]; then \
			echo "Removing existing symlink $$dest"; \
			rm "$$dest"; \
		fi; \
		echo "Linking $$dest -> $(DOTCLAUDE_DIR)/$$target"; \
		ln -s "$(DOTCLAUDE_DIR)/$$target" "$$dest"; \
	done

uninstall:
	@for target in $(TARGETS); do \
		dest="$(TARGET_DIR)/$$target"; \
		if [ -L "$$dest" ]; then \
			echo "Removing symlink $$dest"; \
			rm "$$dest"; \
			if [ -e "$$dest.bak" ]; then \
				echo "Restoring $$dest from $$dest.bak"; \
				mv "$$dest.bak" "$$dest"; \
			fi; \
		fi; \
	done
