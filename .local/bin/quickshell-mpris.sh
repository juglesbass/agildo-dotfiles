#!/bin/bash
STATUS=$(playerctl status 2>/dev/null || echo "Stopped")
if [ "$STATUS" = "Stopped" ]; then
    echo "Stopped|||||"
    exit 0
fi

TITLE=$(playerctl metadata --format '{{title}}' 2>/dev/null)
ARTIST=$(playerctl metadata --format '{{artist}}' 2>/dev/null)
ARTURL=$(playerctl metadata --format '{{mpris:artUrl}}' 2>/dev/null)
POS=$(playerctl position 2>/dev/null || echo "0")
LEN=$(playerctl metadata mpris:length 2>/dev/null || echo "0")

echo "$STATUS|$TITLE|$ARTIST|$ARTURL|$POS|$LEN"
