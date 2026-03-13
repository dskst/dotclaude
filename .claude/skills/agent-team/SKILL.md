---
name: agent-team
description: |
  複数の専門エージェントからなる協調チームを編成し、ロールベースでタスクを実行するスキル。
  devils-advocate による批判的レビューを組み込む。
  ユーザーが「チームで取り組んで」「複数の視点でレビューして」「エージェントチームを使って」と言ったとき、
  または複雑なタスクで明らかに複数の専門性が必要なとき（大規模な機能実装、アーキテクチャ設計、
  セキュリティレビュー、リファクタリングなど）に、このスキルを使用すること。
  単一エージェントで十分な単純タスクには使わない。
allowed-tools: TeamCreate, TeamDelete, TaskCreate, TaskUpdate, TaskList, TaskGet, SendMessage, Read, Write, Bash, AskUserQuestion
---

# Agent Team

専門エージェントの協調チームを作成・管理し、品質保証を組み込みながら複雑なタスクを実行する。

## コンセプト

1 つのエージェントでは見落としが生まれる。複数の専門ロールが協調し、かつ批判的なレビューが入ることで、より堅牢な成果が得られる。このスキルは Claude Code のカスタムサブエージェント（`.claude/agents/*.md`）とチーム機能を組み合わせて、この協調を実現する。

## ロール

エージェントロールは `.claude/agents/` に Markdown ファイルとして定義されている。利用可能なロールは次のコマンドで確認する：

```bash
ls .claude/agents/*.md | xargs -n1 basename -s .md
```

### devils-advocate — 全チーム必須

どんなチームにも必ず devils-advocate を含める。理由：チームが全員同じ方向を向いているとき、仮定の誤りやエッジケースは見過ごされやすい。批判的レビュー役がいることで、問題が本番に到達する前に発見できる。これは「批判のための批判」ではなく、建設的な異議を通じて成果の質を引き上げる仕組みだ。

### ロール組み合わせの目安

タスクの性質に応じて適切なロールを選ぶ。以下は出発点として使う：

| タスクの種類 | 推奨ロール |
|---|---|
| 機能実装 | architect, backend/frontend, reviewer, tester, devils-advocate |
| セキュリティ | security, backend, reviewer, devils-advocate |
| リファクタリング | architect, backend/frontend, reviewer, devils-advocate |
| ドキュメント | documenter, reviewer, devils-advocate |
| バグ修正 | backend/frontend, tester, reviewer, devils-advocate |
| データ | data-engineer, reviewer, devils-advocate |
| インフラ | devops, cloud-engineer, sre, devils-advocate |

これはあくまで目安であり、タスクの要件に応じて自由に組み合わせを変える。

## 実行プロセス

### 1. タスク分析とロール選択

ユーザーのタスクを分析し、必要なロールを決定する。

- `.claude/agents/` の利用可能なロールを確認する
- タスクの性質に合ったロールを選ぶ（上記の組み合わせ表を参考に）
- devils-advocate を含めることを忘れない
- タスクが曖昧な場合は AskUserQuestion でユーザーに確認する

### 2. チーム作成

TeamCreate でチームを立ち上げる。チーム名はタスクの内容がわかる名前にする。

```json
{
  "team_name": "task-[簡潔な説明]",
  "description": "[タスクの概要と目的]",
  "agent_type": "team-lead"
}
```

### 3. タスク分解

主要な作業項目ごとに TaskCreate でタスクを作成する。各タスクには明確な完了条件を含める。

### 4. チームメイト起動

選択したロールごとにサブエージェントを起動する。`.claude/agents/[role-id].md` のロール定義が自動的に読み込まれるため、`subagent_type` にロール ID を指定するだけでよい。

プロンプトには以下の文脈を含める：
- 現在のタスクの詳細と要件
- チーム名とメンバー構成
- チーム連携の方法（TaskList でタスク確認、TaskUpdate で担当、SendMessage で連絡）

```json
{
  "subagent_type": "[role-id]",
  "description": "[Role] for [task-name]",
  "prompt": "タスク文脈:\n[詳細]\n\nチーム情報:\n- チーム名: task-[name]\n- あなたのロール: [role]\n\nチーム連携:\n1. TaskList でタスクを確認\n2. 自分のロールに合うタスクを TaskUpdate で担当\n3. 作業を実施\n4. 必要に応じて SendMessage で他メンバーと連携\n5. 完了したら TaskUpdate でステータスを更新",
  "team_name": "task-[name]",
  "name": "[role-id]"
}
```

### 5. 実行の調整

チームリードとして全体を調整する：

- チームメンバーからのメッセージを監視する（自動で届く）
- アイドルなメンバーにタスクを割り当てる
- メンバー間のコミュニケーションを促進する
- 対立やブロッカーを解消する
- devils-advocate に定期的にレビューを依頼する
- TaskList で進捗を追う

チームメイトがターン間でアイドルになるのは正常な動作。チームリードの役割は調整であり、自分で全作業を担うことではない。

### 6. チームシャットダウン

1. SendMessage で全メンバーにシャットダウンを通知する
2. 確認を待つ
3. TeamDelete でリソースをクリーンアップする

### 7. サマリー報告

ユーザーに以下を伝える：
- 完了した作業の要約
- 主な技術的判断とその理由
- devils-advocate が特定・解消した問題

## 実行例

```
ユーザー: 「JWT を使ったユーザー認証を実装して」

1. ロール選択 → architect, backend, security, tester, devils-advocate
2. チーム作成 → "task-auth-jwt"
3. タスク分解:
   - 認証アーキテクチャの設計
   - JWT 生成・検証の実装
   - セキュリティミドルウェアの追加
   - テストカバレッジの作成
   - セキュリティレビュー
4. 5 エージェント起動、各自がタスクを担当
5. 調整: architect が設計 → backend が実装 → security がレビュー
         → tester がテスト → devils-advocate が全体に異議
6. シャットダウン
7. サマリー報告
```

## トラブルシューティング

| 問題 | 対処 |
|---|---|
| チームメイトが応答しない | 未完了タスクでブロックされていないか確認する |
| devils-advocate が消極的 | 批判的レビューを直接依頼するメッセージを送る |
| タスクの競合 | SendMessage でメンバー間の議論を促す |
