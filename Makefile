DOTCLAUDE_DIR := $(abspath .claude)
TARGET_DIR := $(HOME)/.claude

TARGETS := CLAUDE.md skills agents commands

.PHONY: install uninstall merge-settings

install: merge-settings
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

merge-settings:
	@if [ ! -f "$(DOTCLAUDE_DIR)/settings.json" ]; then \
		echo "Skipping: $(DOTCLAUDE_DIR)/settings.json not found"; \
		exit 0; \
	fi
	@if ! command -v jq >/dev/null 2>&1; then \
		echo "Error: jq is required. Install it with: brew install jq"; \
		exit 1; \
	fi
	@# NOTE: jq の * 演算子は配列値をマージせず上書きする
	@if [ ! -f "$(TARGET_DIR)/settings.json" ]; then \
		echo "Creating $(TARGET_DIR)/settings.json"; \
		cp "$(DOTCLAUDE_DIR)/settings.json" "$(TARGET_DIR)/settings.json"; \
	else \
		if [ ! -f "$(TARGET_DIR)/settings.json.bak" ]; then \
			echo "Backing up $(TARGET_DIR)/settings.json to $(TARGET_DIR)/settings.json.bak"; \
			cp "$(TARGET_DIR)/settings.json" "$(TARGET_DIR)/settings.json.bak"; \
		fi; \
		echo "Merging $(DOTCLAUDE_DIR)/settings.json into $(TARGET_DIR)/settings.json"; \
		jq -s '.[0] * .[1]' "$(TARGET_DIR)/settings.json" "$(DOTCLAUDE_DIR)/settings.json" > "$(TARGET_DIR)/settings.json.tmp" && \
		mv "$(TARGET_DIR)/settings.json.tmp" "$(TARGET_DIR)/settings.json"; \
	fi

uninstall:
	@if [ -f "$(TARGET_DIR)/settings.json.bak" ]; then \
		echo "Restoring $(TARGET_DIR)/settings.json from $(TARGET_DIR)/settings.json.bak"; \
		mv "$(TARGET_DIR)/settings.json.bak" "$(TARGET_DIR)/settings.json"; \
	fi
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
