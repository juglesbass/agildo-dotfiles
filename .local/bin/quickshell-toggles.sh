#!/bin/bash
case "$1" in
  status)
    WIFI=$(nmcli radio wifi 2>/dev/null)
    BT=$(timeout 0.3 rfkill list bluetooth 2>/dev/null | grep -i "Soft blocked: yes" && echo "off" || echo "on")
    DND=$(makoctl mode 2>/dev/null | grep -q "dnd" && echo "on" || echo "off")
    echo "${WIFI:-enabled} ${BT:-off} ${DND:-off}"
    ;;
  wifi-toggle)
    WIFI=$(nmcli radio wifi 2>/dev/null)
    if [ "$WIFI" = "enabled" ]; then
      nmcli radio wifi off
    else
      nmcli radio wifi on
    fi
    ;;
  bluetooth-toggle)
    rfkill toggle bluetooth 2>/dev/null || true
    ;;
  dnd-toggle)
    makoctl mode -t dnd 2>/dev/null || true
    ;;
esac
