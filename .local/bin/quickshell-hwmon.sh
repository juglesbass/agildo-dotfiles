#!/bin/bash
CPU=$(cat /sys/class/hwmon/hwmon3/temp1_input 2>/dev/null | awk '{print int($1/1000)}')
GPU=$(cat /sys/class/drm/card*/device/hwmon/hwmon*/temp1_input 2>/dev/null | head -n 1 | awk '{print int($1/1000)}')
RAM=$(free -m | awk '/Mem/ {printf("%d", ($3/$2)*100)}')
UPTIME=$(uptime -p 2>/dev/null | sed 's/up /Ativo: /' | sed 's/hours/horas/' | sed 's/hour/hora/' | sed 's/minutes/minutos/' | sed 's/minute/minuto/')
echo "${CPU:-0} ${GPU:-0} ${RAM:-0} | ${UPTIME:-Ativo}"
