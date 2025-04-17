# URLリダイレクトチェッカー (Ruby)

このスクリプトは、URLのリスト（CSVまたはテキストファイル）をチェックし、リダイレクトのステータスと遷移先URLを出力します。  
CSV形式またはJSON形式での出力に対応しています。

---

## ✅ 必要条件

- Rubyがインストールされていること（推奨バージョン: **Ruby 3.4.3** 以上）
- 追加のGemは不要（Ruby標準ライブラリのみを使用）

Rubyがインストールされていない場合は、まずインストールしてください。

---

## ✨ 特徴
- CSVファイルおよび単純なテキストファイルからの入力をサポート
- CSVヘッダーの有無を自動検出
- 初期リダイレクトステータスコード（例: 301）を記録
- リダイレクト後の最終URLを記録
- エラー時のリトライ処理を実装
- リクエスト間隔、リトライ回数、タイムアウトを設定可能
- 結果をCSVまたはJSON形式で出力
- コマンドラインオプション対応

---

## 🛠 使用方法

```bash
ruby check_redirects.rb [options]
```

### 必須オプション
| オプション                | 説明                       |
|:---------------------|:-------------------------|
| `-i`, `--input FILE` | 入力ファイルパス（CSVまたはテキストファイル） |

### 任意オプション
| オプション                   | 説明                     | デフォルト値 |
|:------------------------|:-----------------------|:-------|
| `-o`, `--output FORMAT` | 出力形式: `csv` または `json` | `csv`  |
| `--sleep SECONDS`       | リクエスト間の待機秒数            | `1`    |
| `--retry-sleep SECONDS` | リトライ間の待機秒数             | `3`    |
| `--max-retries N`       | 最大リトライ回数               | `3`    |
| `--timeout SECONDS`     | リクエストのタイムアウト秒数         | `10`   |
| `-h`, `--help`          | ヘルプメッセージを表示            |        |

---

## 📚 使用例

**CSVファイルで入力 CSV形式で出力（デフォルト）：**
```bash
ruby check_redirects.rb -i urls.csv
```

**テキストファイルで入力 JSON形式で出力：**
```bash
ruby check_redirects.rb -i url_list.txt -o json
```

**カスタム設定：**
```bash
ruby check_redirects.rb -i urls.csv -o json --sleep 5 --retry-sleep 10 --max-retries 5 --timeout 20
```

**ヘルプを表示：**
```bash
ruby check_redirects.rb -h
```

---

## 📂 入力ファイル形式

### CSV

```csv
URL,Last Modified
https://example.com/page1,2025-03-07T13:14:12+00:00
https://example.com/page2,2025-03-07T13:13:35+00:00
```
- 最初の行が `http://` または `https://` で始まる場合、ヘッダーなしとして扱われます。

### プレーンテキストリスト

```text
https://example.com/page1
https://example.com/page2
https://example.com/page3
```

---

## 📦 出力ファイル

| フィールド                        | 説明                                  |
|:-----------------------------|:------------------------------------|
| Old URL                      | チェックした元のURL                         |
| Final URL                    | リダイレクト後の最終遷移先URL                    |
| Redirect Status Code / Error | 初期リダイレクトステータスコード（例: 301）またはエラーメッセージ |

### 出力ファイル名：
- CSVの場合: `urls_results.csv`
- JSONの場合: `urls_results.json`

---

## 📋 注意事項
- スクリプトは最初に `HEAD` リクエストを使用して負荷を最小限に抑えます。一部のサーバーでは `HEAD` を正しく処理できない場合があります。その場合、スクリプトを修正して `GET` を使用する必要があります。
- タイムアウトやリトライ回数はコマンドラインオプションで設定可能です。
- 外部Gemは不要です。

---

