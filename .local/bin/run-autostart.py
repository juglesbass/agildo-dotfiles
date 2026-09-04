#!/usr/bin/env python3
import os
import glob
import subprocess
import shlex

autostart_dir = os.path.expanduser("~/.config/autostart")
if not os.path.isdir(autostart_dir):
    exit(0)

for f in sorted(glob.glob(os.path.join(autostart_dir, "*.desktop"))):
    try:
        with open(f, "r", encoding="utf-8", errors="ignore") as file:
            lines = file.readlines()

        props = {}
        for line in lines:
            line = line.strip()
            if "=" in line and not line.startswith("#"):
                k, v = line.split("=", 1)
                props[k.strip()] = v.strip()

        # Check if disabled
        if props.get("Hidden", "").lower() == "true":
            continue
        if props.get("X-GNOME-Autostart-enabled", "").lower() == "false":
            continue

        exec_cmd = props.get("Exec")
        if exec_cmd:
            # Strip standard desktop entry spec field codes (%u, %f, %U, %F, %i, %c, %k)
            args = shlex.split(exec_cmd)
            clean_args = [arg for arg in args if not (arg.startswith("%") and len(arg) == 2)]
            if clean_args:
                subprocess.Popen(clean_args, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
                print(f"[autostart] Iniciado: {clean_args[0]}")
    except Exception as e:
        print(f"[autostart] Erro ao ler {f}: {e}")
