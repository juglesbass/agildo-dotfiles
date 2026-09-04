#!/bin/bash
CUR_WS=$(hyprctl activeworkspace -j | jq -r '.id')
if [ "$CUR_WS" == "99" ]; then CUR_WS="1"; fi
LAST_WIN=$(hyprctl clients -j | jq -r 'map(select(.workspace.id == 99 or .workspace.name == "99")) | last | .address')
if [ "$LAST_WIN" != "null" ] && [ -n "$LAST_WIN" ]; then
    hyprctl repl "hl.dispatch(hl.dsp.window.move({ workspace = \"$CUR_WS\", window = \"address:$LAST_WIN\", silent = true })); hl.dispatch(hl.dsp.focus({ window = \"address:$LAST_WIN\" })); hl.dispatch(hl.dsp.focus({ workspace = \"$CUR_WS\" }))"
fi
