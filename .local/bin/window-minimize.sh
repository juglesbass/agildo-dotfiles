#!/bin/bash
ACTION="$1"

if [ "$ACTION" = "minimize" ]; then
    ACTIVE_WS=$(hyprctl activeworkspace -j | jq -r '.id // 1')
    if [ "$ACTIVE_WS" = "99" ]; then
        hyprctl dispatch workspace 1
    else
        hyprctl dispatch movetoworkspacesilent 99
    fi

elif [ "$ACTION" = "restore" ]; then
    ADDR=$(hyprctl clients -j | jq -r '[.[] | select((.workspace.id == 99 or .workspace.name == "99") and .class != "dev.noctalia.Noctalia")] | last | .address // empty')
    [ -z "$ADDR" ] && exit 0
    ACTIVE_WS=$(hyprctl activeworkspace -j | jq -r '.id // 1')
    [ "$ACTIVE_WS" = "99" ] && ACTIVE_WS=1
    hyprctl --batch "dispatch movetoworkspace ${ACTIVE_WS},address:${ADDR}; dispatch focuswindow address:${ADDR}"

elif [ "$ACTION" = "toggle" ]; then
    ACTIVE_ADDR=$(hyprctl activewindow -j | jq -r '.address // empty')
    ACTIVE_WS=$(hyprctl activeworkspace -j | jq -r '.id // 1')
    if [ "$ACTIVE_WS" = "99" ]; then
        hyprctl dispatch workspace 1
    elif [ -n "$ACTIVE_ADDR" ] && [ "$ACTIVE_ADDR" != "null" ]; then
        hyprctl dispatch movetoworkspacesilent 99
    else
        ADDR=$(hyprctl clients -j | jq -r '[.[] | select((.workspace.id == 99 or .workspace.name == "99") and .class != "dev.noctalia.Noctalia")] | last | .address // empty')
        if [ -n "$ADDR" ] && [ "$ADDR" != "null" ]; then
            [ "$ACTIVE_WS" = "99" ] && ACTIVE_WS=1
            hyprctl --batch "dispatch movetoworkspace ${ACTIVE_WS},address:${ADDR}; dispatch focuswindow address:${ADDR}"
        fi
    fi
fi
