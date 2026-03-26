# dotclaude

A dotfiles repository for managing Claude Code user settings — CLAUDE.md, custom agents, skills, and configuration files. Run `make install` to symlink everything into `~/.claude/`.

**[日本語版 README](README.ja.md)**

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- [jq](https://jqlang.github.io/jq/) (used to merge settings.json)

## Install

```bash
git clone https://github.com/dskst/dotclaude.git
cd dotclaude
make install
```

`make install` does the following:

1. Merges `settings.json` into `~/.claude/settings.json` (backs up existing file if present)
2. Symlinks `CLAUDE.md`, `skills/`, and `agents/` into `~/.claude/` (backs up existing files if present)

## Uninstall

```bash
make uninstall
```

Removes symlinks and restores backups if they exist. `settings.json` is also restored from backup.

## Structure

```
.claude/
├── CLAUDE.md                          # Global instructions (style settings, etc.)
├── settings.json                      # Shared settings (permissions, env vars, plugins)
├── settings.local.json                # Local-only settings (not intended for sharing)
├── agents/                            # Custom sub-agent definitions
└── skills/                            # Custom skill definitions
```

### Settings

`settings.json` includes:

- **Environment variables**: Enables agent teams (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`)
- **Permissions (deny)**: Blocks destructive commands (`git push --force`, `rm -rf`) and reading sensitive files (`.env`, `.pem`)
- **Plugins**: Enables `document-skills`
- **Team mode**: tmux

## Customization

### Adding an agent

Add a Markdown file to `.claude/agents/`. Define `name`, `description`, `model`, `color`, etc. in the YAML frontmatter, and write the system prompt in the body.

### Adding a skill

Create `.claude/skills/<skill-name>/SKILL.md`. Define `name`, `description`, `allowed-tools` in the YAML frontmatter, and write the execution steps in the body.

## License

MIT
