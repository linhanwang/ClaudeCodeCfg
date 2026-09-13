## Documentation

- Docs meant for human reading (design docs, plans, reports) must stay concise: verdicts, decisions, and pointers only — move detailed receipts, forensics, and dead ends to archive files or results dirs.

## Git Preferences

- Do not commit automatically. Only commit when explicitly asked.
- Keep commit messages concise: one short subject line, no bullet-point body.

## Process Management

- Only kill processes by exact PID I launched this session. Never `pkill -f`, `killall`, or pattern-based kills unless the user explicitly asks.
- Terminate with graceful `SIGTERM` (`kill <pid>`) and give the process time to exit. Never `kill -9`/`SIGKILL`: GPU jobs (MuJoCo/EGL/CUDA) skipped past their cleanup handlers leave EGL contexts dangling, which is what caused the GPU driver failure we hit.
- Never run `nvidia-smi --gpu-reset` or other driver-level resets.

@RTK.md
