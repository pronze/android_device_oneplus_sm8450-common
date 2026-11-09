#!/usr/bin/env bash

# oplus_kmsg_wb.ko log collector

set -euo pipefail

OUT_DIR="oplus_kmsg_logs/${1:-$(date +%F)-log}"

if ! adb get-state >/dev/null 2>&1; then
    echo "Error: No device connected via ADB." >&2
    exit 1
fi

mkdir -p "$OUT_DIR"
TMP_HDR="$(mktemp)"
TMP_SLOTS="$(mktemp)"
trap 'rm -f "$TMP_HDR" "$TMP_SLOTS"' EXIT

echo "==> Extracting header from oplusreserve5..."
adb exec-out "dd if=/dev/block/by-name/oplusreserve5 bs=4096 skip=1024 count=1 2>/dev/null" \
    | head -c 4096 > "$TMP_HDR"

echo "==> Parsing header and calculating slot info..."
python3 - "$TMP_HDR" <<'EOF'
import struct, sys

try:
    with open(sys.argv[1], 'rb') as f:
        d = f.read()

    bc, = struct.unpack_from('<Q', d, 0)
    slot = bc % 8
    offset = 4 * 1024 * 1024 + 4096 + slot * 512 * 4096

    print(f"-> Magic: {d[8:20]}")
    print(f"-> Bootcount: {bc}")
    print(f"-> Latest slot: {slot}")
    print(f"-> Calculated offset: {offset}")
except Exception as e:
    print(f"Error parsing header: {e}", file=sys.stderr)
    sys.exit(1)
EOF

echo "==> Dumping 16 MB slot data..."
adb exec-out "dd if=/dev/block/by-name/oplusreserve5 bs=4096 skip=1025 count=4096 2>/dev/null" \
    | head -c 16777216 > "$TMP_SLOTS"

echo "==> Splitting into 2 MB chunks (slot_) in $OUT_DIR/ ..."
split -b 2097152 "$TMP_SLOTS" "$OUT_DIR/slot_"

echo "==> Done! Chunks saved in '$OUT_DIR/' with prefix 'slot_'."
ls -l "$OUT_DIR"