#!/bin/bash
cliphist list | rofi -dmenu -p 'Colar Item Copiado' -theme-str 'window {width: 45%;} listview {lines: 10;}' | cliphist decode | wl-copy
