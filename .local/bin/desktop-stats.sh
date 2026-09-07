#!/usr/bin/env bash
# ==============================================================================
# 📊 Sensores para o widget de area de trabalho (~/.config/quickshell/desktop)
# ==============================================================================
# Escreve uma linha JSON com temperatura de CPU e GPU e uso de RAM.
#
# Os sensores sao resolvidos pelo NOME em /sys/class/hwmon/*/name, nunca pelo
# numero do hwmon: essa numeracao depende da ordem em que os modulos carregam e
# muda entre arranques. Aqui, hoje, o k10temp calhou de ser o hwmon2 e o amdgpu
# o hwmon1 -- amanha podem trocar.
#
# Tudo sai de sysfs e /proc, sem processos auxiliares: o widget chama isto a
# cada poucos segundos e nao vale a pena pagar por um `sensors` ou `free`.
set -uo pipefail

hwmon_by_name() {
    local want=$1 h
    for h in /sys/class/hwmon/hwmon*; do
        [ "$(cat "$h/name" 2>/dev/null)" = "$want" ] && { echo "$h"; return 0; }
    done
    return 1
}

read_milli_c() {  # ficheiro -> graus inteiros, ou vazio
    local f=$1 v
    [ -r "$f" ] || return 1
    v=$(cat "$f" 2>/dev/null) || return 1
    [ -n "$v" ] || return 1
    echo $(( v / 1000 ))
}

# ---- CPU: k10temp (AMD) ou coretemp (Intel); Tctl/Package fica no temp1 ----
cpu=""
for n in k10temp coretemp; do
    if h=$(hwmon_by_name "$n"); then
        cpu=$(read_milli_c "$h/temp1_input") && break
    fi
done
# Ultimo recurso: o primeiro temp1_input que exista.
[ -z "$cpu" ] && cpu=$(read_milli_c "$(ls /sys/class/hwmon/hwmon*/temp1_input 2>/dev/null | head -1)")

# ---- GPU: amdgpu/nvidia via hwmon; senao nvidia-smi ----
gpu=""
for n in amdgpu nvidia radeon i915 xe; do
    if h=$(hwmon_by_name "$n"); then
        gpu=$(read_milli_c "$h/temp1_input") && break
    fi
done
if [ -z "$gpu" ] && command -v nvidia-smi >/dev/null 2>&1; then
    gpu=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -1)
fi

# ---- RAM: MemAvailable e' o numero honesto (MemFree ignora cache reclamavel) ----
ram_pct=""; ram_used=""; ram_total=""
if [ -r /proc/meminfo ]; then
    read -r ram_pct ram_used ram_total < <(awk '
        /^MemTotal:/     { t = $2 }
        /^MemAvailable:/ { a = $2 }
        END {
            if (t > 0) {
                used = t - a
                printf "%d %.1f %.1f\n", (used * 100 / t) + 0.5, used / 1048576, t / 1048576
            }
        }' /proc/meminfo)
fi

j() { [ -n "${1:-}" ] && echo -n "$1" || echo -n "null"; }
printf '{"cpuTemp":%s,"gpuTemp":%s,"ramPct":%s,"ramUsed":%s,"ramTotal":%s}\n' \
    "$(j "$cpu")" "$(j "$gpu")" "$(j "$ram_pct")" "$(j "$ram_used")" "$(j "$ram_total")"
