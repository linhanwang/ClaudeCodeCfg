#!/usr/bin/env bash
# Ring the terminal bell on whichever pane the firing Claude process is on.
# The previous hook fanned \a out to every writable /dev/pts/*, which made
# tmux flag unrelated adjacent panes (nvim, nvtop, bash) with `!` on every
# Notification/Stop event.

p=$PPID
while [ "${p:-0}" -gt 1 ]; do
  read -r comm < /proc/"$p"/comm 2>/dev/null || break
  if [ "$comm" = "claude" ]; then
    tty=$(ps -o tty= -p "$p" 2>/dev/null | tr -d ' ')
    if [ -n "$tty" ] && [ "$tty" != "?" ] && [ -w "/dev/$tty" ]; then
      printf '\a' > "/dev/$tty"
    fi
    exit 0
  fi
  p=$(awk '/^PPid:/{print $2; exit}' /proc/"$p"/status 2>/dev/null)
done
