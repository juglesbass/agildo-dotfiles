#!/bin/bash
CUR_WS=$(hyprctl activeworkspace -j | jq -r '.id')
if [ "$CUR_WS" == "99" ]; then CUR_WS="1"; fi
WIN=$(hyprctl activewindow -j | jq -r '.address')
if [ "$WIN" != "null" ] && [ -n "$WIN" ]; then
    hyprctl repl "hl.dispatch(hl.dsp.window.move({ workspace = \"99\", window = \"address:$WIN\", silent = true })); hl.dispatch(hl.dsp.focus({ workspace = \"$CUR_WS\" }))"
fi
