#!/bin/sh
# Serve FocusLab single-file app. Empty directory listing must NOT count as healthy.
set -e
ROOT=/workspace/artifacts
INDEX="$ROOT/index.html"

if [ ! -f "$INDEX" ]; then
  echo "startup: missing $INDEX" >&2
  exit 1
fi

healthy() {
  curl -sf --max-time 2 http://127.0.0.1:8080/index.html | grep -q '<title>FocusLab</title>'
}

if healthy; then
  exit 0
fi

# Kill stale python server (often serving empty dir)
pkill -f 'python3 -m http.server 8080' 2>/dev/null || true
sleep 0.2

cd "$ROOT"
python3 -m http.server 8080 --bind 0.0.0.0 >/tmp/focuslab-http.log 2>&1 &
sleep 0.5
healthy || { echo "startup: FocusLab not serving" >&2; exit 1; }
exit 0
