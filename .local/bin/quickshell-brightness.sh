#!/bin/bash
case "$1" in
  get)
    cat /tmp/quickshell_brightness 2>/dev/null || echo "100"
    ;;
  set)
    VAL="$2"
    echo "$VAL" > /tmp/quickshell_brightness
    brightnessctl set "${VAL}%" 2>/dev/null || true
    ;;
esac
