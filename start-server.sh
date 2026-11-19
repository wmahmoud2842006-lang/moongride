#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

export PHP_CLI_SERVER_WORKERS=4

PORT=8000
PUBLIC_DIR="$SCRIPT_DIR/test/lunar-south-pole-backend/public"
if [ ! -d "$PUBLIC_DIR" ]; then
    PUBLIC_DIR="$SCRIPT_DIR/public"
fi

if [ -d "$SCRIPT_DIR/tools/bin" ]; then
    export PATH="$SCRIPT_DIR/tools/bin:$PATH"
fi

echo "======================================================="
echo "         MOONGRIDE MULTI-THREADED SERVER (Linux/macOS)"
echo "======================================================="
echo "PHP_CLI_SERVER_WORKERS=4"
echo "Web Root: $PUBLIC_DIR"
echo "Starting on http://127.0.0.1:$PORT ..."

php -S 127.0.0.1:$PORT -t "$PUBLIC_DIR"
