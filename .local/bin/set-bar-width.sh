#!/bin/bash
WIDTH="$1"
if [ -z "$WIDTH" ]; then
    echo "Usage: $0 <width_in_px>"
    exit 1
fi

python3 -c "
import json, os

path = os.path.expanduser('~/.config/caelestia/shell-tokens.json')
try:
    with open(path) as f:
        d = json.load(f)
except Exception:
    d = {}

d.setdefault('sizes', {}).setdefault('bar', {})['innerWidth'] = int('$WIDTH')
with open(path, 'w') as f:
    json.dump(d, f, indent=4)
"
