# nexusgen4561/tap

Homebrew tap.

```bash
brew install nexusgen4561/tap/claude-usage-bar
```

| Formula | What it is |
| --- | --- |
| [`claude-usage-bar`](Formula/claude-usage-bar.rb) | macOS menu bar widget for Claude usage limits — [repo](https://github.com/nexusgen4561/claude-usage-bar) |

## Releasing a new version

1. Tag the source repo: `git tag -a v1.1.0 -m v1.1.0 && git push origin v1.1.0`
2. Get the checksum:
   ```bash
   curl -sL https://github.com/nexusgen4561/claude-usage-bar/archive/refs/tags/v1.1.0.tar.gz | shasum -a 256
   ```
3. Update `url` and `sha256` in the formula, then `brew audit --strict --new nexusgen4561/tap/claude-usage-bar`
4. Commit and push. Users get it on their next `brew update && brew upgrade`.
