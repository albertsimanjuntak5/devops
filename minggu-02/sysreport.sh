#!/usr/bin/env bash
set -euo pipefail

# Fungsi menampilkan panduan penggunaan
usage() {
    echo "Penggunaan: $0 [--summary | --json | --check-port PORT]"
    exit 1
}

# Evaluasi argumen baris perintah
if [ $# -eq 0 ]; then
    usage
fi

case "$1" in
    --summary)
        echo "=== RINGKASAN SISTEM ==="
        echo "Hostname    : $(hostname)"
        echo "Kernel      : $(uname -r)"
        echo "Uptime      : $(uptime -p)"
        echo "Penggunaan Disk /: $(df -h / | awk 'NR==2 {print $5}')"
        exit 0
        ;;
    --json)
        echo "{"
        echo "  \"hostname\": \"$(hostname)\","
        echo "  \"kernel\": \"$(uname -r)\","
        echo "  \"disk_usage\": \"$(df -h / | awk 'NR==2 {print $5}')\""
        echo "}"
        exit 0
        ;;
    --check-port)
        if [ -z "${2:-}" ]; then
            echo "Eror: Port harus ditentukan." >&2
            exit 2
        fi
        PORT="$2"
        if ss -tuln | grep -q ":$PORT "; then
            echo "Port $PORT AKTIF (sedang mendengarkan)."
            exit 0
        else
            echo "Port $PORT TIDAK AKTIF."
            exit 3
        fi
        ;;
    *)
        usage
        ;;
esac
