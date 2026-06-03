# Claude Settings

## Style

- 常に日本語で返信する
- である調で返信する
- ドキュメントは日本語で記載する

## Guidelines

### Action Guidelines

- 成功条件を定義してから行動する
- 複雑な作業は計画を提示する
- 不明瞭な指示に対して推測で行動しない
- 複雑なものを削ぎ落としてシンプルな出力をする

### Develop Guidelines

- SOLID の原則を守る
- TDD で開発をする
- 変更前後でテストが通ることを確認する
- 指示があるまで `git commit` / `git push` はしない
- 問題を解決する最小限のコードを書く
- 必要な箇所だけ変更する
- 不要なコードは削除提案をする

### Editor Guidelines

コードナビゲーションには、 Grep/Read よりも LSP を優先する。

- `workspaceSymbol` で定義箇所を検索
- `findReferences` でコードベース全体での使用箇所を表示
- `goToDefinition` / `goToImplementation` で定義元/実装先にジャンプ
- `hover` でファイルを読まずに型情報を表示

LSP が利用できない場合、またはテキスト/パターン検索を行う場合にのみ Grep を使用する。
コードの記述または編集後は、 LSP 診断を確認し、エラーを修正してから作業を進める。
