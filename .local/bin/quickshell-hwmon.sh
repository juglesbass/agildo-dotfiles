#!/bin/bash
# ==============================================================================
# 📊 Hardware Monitor for Caelestia Shell (Quickshell)
# ==============================================================================

# 1. Detect CPU temperature dynamically (k10temp for AMD, coretemp for Intel, or fallback)
CPU_TEMP_FILE=""
for h in /sys/class/hwmon/hwmon*; do
    NAME=$(cat "$h/name" 2>/dev/null)
    if [ "$NAME" = "k10temp" ] || [ "$NAME" = "coretemp" ]; then
        if [ -f "$h/temp1_input" ]; then
            CPU_TEMP_FILE="$h/temp1_input"
            break
        fi
    fi
done
[ -z "$CPU_TEMP_FILE" ] && CPU_TEMP_FILE=$(ls /sys/class/hwmon/hwmon*/temp1_input 2>/dev/null | head -n 1)

CPU=$(cat "$CPU_TEMP_FILE" 2>/dev/null | awk '{print int($1/1000)}')

# 2. Detect GPU temperature dynamically (AMD/Intel DRM sysfs)
GPU=$(cat /sys/class/drm/card*/device/hwmon/hwmon*/temp1_input 2>/dev/null | head -n 1 | awk '{print int($1/1000)}')
if [ -z "$GPU" ] || [ "$GPU" -eq 0 ] 2>/dev/null; then
    # Fallback to nvidia-smi if Nvidia GPU
    if command -v nvidia-smi >/dev/null 2>&1; then
        GPU=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n 1)
    fi
fi

# 3. RAM usage percentage
RAM=$(free -m | awk '/Mem/ {printf("%d", ($3/$2)*100)}')

# 4. System Uptime
UPTIME=$(uptime -p 2>/dev/null | sed 's/up /Ativo: /' | sed 's/hours/horas/' | sed 's/hour/hora/' | sed 's/minutes/minutos/' | sed 's/minute/minuto/')

echo "${CPU:-0} ${GPU:-0} ${RAM:-0} | ${UPTIME:-Ativo}"
