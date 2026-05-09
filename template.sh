#!/bin/bash

SESSION="my_session"
PROJECT_DIR="$PWD"

attach() {
    if [ -n "$TMUX" ]; then
        tmux switch-client -t "$SESSION"
    else
        tmux attach-session -t "$SESSION"
    fi
}

send() {
    tmux send-keys -t "$1" "$2" C-m
}

if tmux has-session -t "$SESSION" 2>/dev/null; then
    attach
    exit 0
fi

# =========================
# NVIM
# =========================

tmux new-session -d -s "$SESSION" -n "nvim" -c "$PROJECT_DIR"

send "$SESSION:nvim" "nvim"

# =========================
# SERVER
# =========================

tmux new-window -t "$SESSION" -n "server" -c "$PROJECT_DIR"

tmux split-window -h -t "$SESSION:server" -c "$PROJECT_DIR"

# NOTE: It is pane 1 and 2 because the 0:th pane is in the first window
send "$SESSION:server.1" "npm run dev"
send "$SESSION:server.2" "python3 main.py"

tmux resize-pane -t "$SESSION:server.1" -R 30

# =========================
# START POSITION
# =========================

tmux select-window -t "$SESSION:nvim"

attach
