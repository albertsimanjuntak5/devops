#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$APP_DIR/.venv"
PORT="${PORT:-5000}"

source "$APP_DIR/lib/common.sh"

log_info "Memulai proses instalasi dan deployment app-sentra..."

log_info "Memeriksa prasyarat..."
command -v python3 >/dev/null || { log_error "python3 tidak ditemukan."; exit 1; }

log_info "Menyiapkan virtual environment..."
[ -d "$VENV_DIR" ] || python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

log_info "Memasang dependensi..."
pip install --quiet --upgrade pip
pip install --quiet -r "$APP_DIR/requirements.txt"

log_info "Menjalankan aplikasi pada port $PORT..."
PORT="$PORT" python3 "$APP_DIR/src/app.py" &
APP_PID=$!

sleep 3
log_info "Melakukan health check..."
if curl -fsS "http://127.0.0.1:$PORT/health" >/dev/null; then
    log_info "SUKSES: Aplikasi berjalan dengan PID $APP_PID."
else
    log_error "GAGAL: Aplikasi tidak merespons pada port $PORT."
    kill "$APP_PID" 2>/dev/null || true
    exit 1
fi
