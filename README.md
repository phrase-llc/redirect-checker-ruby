# URL Redirect Checker (Ruby)

This script checks a list of URLs (from CSV or text file) and outputs the redirect status and final destination.  
It supports both CSV and JSON output formats, and is useful for domain migration or link audit tasks.

---

## ✅ Requirements

- Ruby installed (Recommended version: **Ruby 3.4.3** or higher)
- No additional gems required (uses only Ruby standard libraries)

If Ruby is not installed, please install it first.

---

## ✨ Features
- Supports input from both CSV files and simple text lists
- Automatically detects header presence
- Records initial redirect status code (e.g., 301)
- Records final destination URL after redirects
- Handles request retries on failure
- Configurable sleep intervals, retries, and timeouts
- Outputs results in CSV or JSON format
- Command-line options via `OptionParser`

---

## 🛠 Usage

```bash
ruby check_redirects.rb [options]
```

### Required Options
| Option               | Description                        |
|:---------------------|:-----------------------------------|
| `-i`, `--input FILE` | Input file path (CSV or text file) |

### Optional Options
| Option                  | Description                    | Default |
|:------------------------|:-------------------------------|:--------|
| `-o`, `--output FORMAT` | Output format: `csv` or `json` | `csv`   |
| `--sleep SECONDS`       | Sleep seconds between requests | `1`     |
| `--retry-sleep SECONDS` | Sleep seconds between retries  | `3`     |
| `--max-retries N`       | Maximum retry attempts         | `3`     |
| `--timeout SECONDS`     | Request timeout in seconds     | `10`    |
| `-h`, `--help`          | Show help message              |         |

---

## 📚 Examples

**Check CSV file and output CSV (default):**
```bash
ruby check_redirects.rb -i urls.csv
```

**Check text file and output JSON:**
```bash
ruby check_redirects.rb -i url_list.txt -o json
```

**Custom settings:**
```bash
ruby check_redirects.rb -i urls.csv -o json --sleep 5 --retry-sleep 10 --max-retries 5 --timeout 20
```

**Show help:**
```bash
ruby check_redirects.rb -h
```

---

## 📂 Input File Formats

### CSV (with or without header)

```csv
URL,Last Modified
https://example.com/page1,2025-03-07T13:14:12+00:00
https://example.com/page2,2025-03-07T13:13:35+00:00
```
- If the first row starts with `http://` or `https://`, it's treated as no header.

### Plain text list

```text
https://example.com/page1
https://example.com/page2
https://example.com/page3
```

---

## 📦 Output File

| Field                        | Description                                               |
|:-----------------------------|:----------------------------------------------------------|
| Old URL                      | The original URL checked                                  |
| Final URL                    | Final destination after redirects                         |
| Redirect Status Code / Error | Initial redirect status code (e.g., 301) or error message |

### Output files:
- For CSV: `urls_results.csv`
- For JSON: `urls_results.json`

---

## 📋 Notes
- The script uses `HEAD` requests first to minimize load. Some servers may not handle `HEAD` correctly; in such cases, modifying the script to use `GET` may be necessary.
- Timeout and retries are configurable via command-line options.
- No external gems are required — all dependencies are Ruby standard libraries.

---

