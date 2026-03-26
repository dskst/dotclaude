# dotclaude

Claude Code のユーザー設定（CLAUDE.md、カスタムエージェント、スキル、設定ファイル）を管理する dotfiles リポジトリである。`make install` でシンボリックリンクを作成し、`~/.claude/` 配下に設定を展開する。

**[English README](README.md)**

## 前提条件

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) がインストールされていること
- [jq](https://jqlang.github.io/jq/) がインストールされていること（settings.json のマージに使用）

## インストール

```bash
git clone https://github.com/dskst/dotclaude.git
cd dotclaude
make install
```

`make install` は以下を実行する：

1. `settings.json` を `~/.claude/settings.json` にマージする（既存ファイルがあればバックアップを作成）
2. `CLAUDE.md`、`skills/`、`agents/`、`commands/` を `~/.claude/` 配下にシンボリックリンクする（既存ファイルがあればバックアップを作成）

## アンインストール

```bash
make uninstall
```

シンボリックリンクを削除し、バックアップがあれば復元する。`settings.json` もバックアップから復元される。

## 構成

```
.claude/
├── CLAUDE.md                          # グローバル指示（スタイル設定など）
├── settings.json                      # 共有設定（権限、環境変数、プラグイン）
├── settings.local.json                # ローカル専用設定（git管理外用途）
├── agents/                            # カスタムサブエージェント定義
├── commands/                          # カスタムスラッシュコマンド定義
└── skills/                            # カスタムスキル定義
```

### 設定

`settings.json` には以下が含まれる：

- **環境変数**: エージェントチーム機能の有効化（`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`）
- **権限（deny）**: 破壊的コマンド（`git push --force`、`rm -rf`）および機密ファイル（`.env`、`.pem`）の読み取りを禁止
- **プラグイン**: `document-skills` の有効化
- **チームモード**: tmux

## カスタマイズ

### エージェントの追加

`.claude/agents/` に Markdown ファイルを追加する。YAML frontmatter で `name`、`description`、`model`、`color` 等を定義し、本文にシステムプロンプトを記述する。

### コマンドの追加

`.claude/commands/` に Markdown ファイルを追加する。ファイル名がスラッシュコマンド名になる（例: `suggest.md` → `/suggest`）。本文にプロンプトテンプレートを記述し、`$ARGUMENTS` でユーザー入力を受け取る。

### スキルの追加

`.claude/skills/<skill-name>/SKILL.md` を作成する。YAML frontmatter で `name`、`description`、`allowed-tools` を定義し、本文に実行手順を記述する。

## ライセンス

MIT
