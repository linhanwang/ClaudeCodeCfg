---
name: r2
description: Cloudflare R2 toolkit — upload/download/list/delete files, get public https or temporary presigned URLs for sharing images, screenshots, logs, and artifacts. Use when the user wants to upload a file to R2, get a shareable link for an image, host a screenshot, download/list/delete R2 objects, generate a presigned link, or asks to "r2up"/"r2 put" something.
---

# R2 Toolkit

A small, S3-compatible Cloudflare R2 CLI (`r2`) with atomic subcommands. The
script is self-contained (`uv run` with inline `boto3`) and reads credentials
from the environment, falling back to `~/.r2env`.

## Invoke

Always call the bundled script by absolute path:

```bash
~/.claude/skills/r2/r2 <subcommand> ...
```

### Subcommands

| Command | What it does |
|---|---|
| `r2 put [-t TAG] [-k KEY] [-q] <file>...` | Upload file(s); prints public URL. `-q` = URL only. |
| `r2 get [-o OUT] <key>...` | Download object(s). `-o` = file (single) or directory. |
| `r2 ls [PREFIX] [-l]` | List keys under a prefix. `-l` adds size + mtime. |
| `r2 rm <key>...` | Delete object(s). |
| `r2 stat <key>` | Metadata (size, type, mtime, etag). Exit 1 if missing → use as an existence check. |
| `r2 url <key>...` | Public r2.dev URL for an existing key (no upload). |
| `r2 sign [-m get\|put\|delete] [-e 2h] <key>...` | Presigned URL for temporary access (default GET, 1h). |
| `r2 cp <src> <dst>` | Server-side copy within the bucket. |
| `r2 mv <src> <dst>` | Move (copy then delete) within the bucket. |
| `r2 sync [-t TAG] <dir>` | Recursively upload a directory (keys preserve the tree). |

### Common patterns

```bash
# Share a screenshot → public link (use -q to get a clean, parseable URL)
~/.claude/skills/r2/r2 put -q shot.png

# Group uploads under a folder-like prefix
~/.claude/skills/r2/r2 put -t demos plot.png

# Temporary private link valid for 2 hours (no public bucket needed)
~/.claude/skills/r2/r2 sign -e 2h reports/run42.csv

# Presigned upload slot someone else can PUT to
~/.claude/skills/r2/r2 sign -m put -e 30m incoming/blob.bin
```

## Which URL to give the user

- **`put` / `url`** return a **public** `https://…r2.dev/…` link — shareable by
  anyone, no expiry. Good for screenshots/artifacts. **Caveat:** r2.dev is
  rate-limited (429s under heavy traffic) and meant for testing/sharing, not
  production hotlinking.
- **`sign`** returns a **presigned** link tied to the S3 endpoint that expires
  (1s–7days). Use this for private buckets or temporary access without making
  anything public. Presigned URLs do **not** work with custom domains.

When reporting an upload, give the user the `https://…` URL; the
`r2://bucket/key` line is just the internal storage path.

## Programmatic use (other scripts/apps)

The operations are plain importable functions:

```python
import sys; sys.path.insert(0, "<home>/.claude/skills/r2")
from r2 import get_client, r2_put, r2_list, presign
s3, bucket = get_client()
print(r2_put(s3, bucket, "shot.png"))                  # -> public URL
print(presign(s3, bucket, "k", method="get", expires=3600))
```
(`boto3` must be importable in that interpreter.)

## Credentials & portability

Secrets are **never** committed to git. The script reads these from the
environment, falling back to `~/.r2env` (machine-local, mode 600) for any unset:

- `R2_ENDPOINT`, `R2_ACCESS_KEY`, `R2_SECRET_KEY`, `R2_BUCKET` (required)
- `R2_DEV` (optional) — public `https://pub-….r2.dev` base URL; enables
  `put`/`url` public links. Without it those still work but print `r2://` paths.

### New-machine setup
1. `uv` installed (the script runs via `uv run`).
2. Create `~/.r2env` with the five `export KEY="value"` lines; `chmod 600 ~/.r2env`.
3. The `r2` script + this skill sync via the `~/.claude` git repo.

`Missing env vars` on run → `~/.r2env` is absent or incomplete.
