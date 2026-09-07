#!/usr/bin/env bash
# ==============================================================================
# 🌤️  Tempo para o widget de area de trabalho
# ==============================================================================
# Escreve uma linha JSON com a condicao actual. Duas fontes, ambas sem chave:
#
#   ip-api.com     -> latitude/longitude a partir do IP. E' o MESMO servico que
#                     o teu caelestia ja' usa (services/Weather.qml), portanto
#                     nao introduz nada de novo em termos de privacidade.
#   open-meteo.com -> a meteorologia propriamente dita.
#
# Para fixar a localizacao a mao e nunca contactar o ip-api, cria:
#   ~/.config/hypr/weather-location   com  "-3.1032 -60.0288 Manaus"
#
# Ha' duas caches, porque as duas coisas mudam a ritmos diferentes: a
# localizacao (1 dia) e o tempo (10 min). Sem isto, um widget que le a cada
# poucos segundos bateria nas APIs milhares de vezes por dia e acabaria
# bloqueado.
set -uo pipefail

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/desktop-weather"
mkdir -p "$CACHE_DIR"
LOC_CACHE="$CACHE_DIR/location.json"
WX_CACHE="$CACHE_DIR/weather.json"
MANUAL="$HOME/.config/hypr/weather-location"

fresh() { # ficheiro, segundos
    [ -r "$1" ] || return 1
    [ $(( $(date +%s) - $(stat -c %Y "$1") )) -lt "$2" ]
}

# ---- localizacao ----
if [ -r "$MANUAL" ]; then
    read -r LAT LON CITY < "$MANUAL"
elif fresh "$LOC_CACHE" 86400; then
    read -r LAT LON CITY < <(python3 -c "
import json;d=json.load(open('$LOC_CACHE'));print(d['lat'],d['lon'],d.get('city',''))" 2>/dev/null)
else
    if curl -sS -m 8 "http://ip-api.com/json?fields=status,city,lat,lon" -o "$LOC_CACHE.tmp" 2>/dev/null \
       && python3 -c "
import json,sys
d=json.load(open('$LOC_CACHE.tmp'))
sys.exit(0 if d.get('status')=='success' else 1)" 2>/dev/null; then
        mv "$LOC_CACHE.tmp" "$LOC_CACHE"
        read -r LAT LON CITY < <(python3 -c "
import json;d=json.load(open('$LOC_CACHE'));print(d['lat'],d['lon'],d.get('city',''))")
    else
        rm -f "$LOC_CACHE.tmp"
        # Sem localizacao nao ha' o que pedir: devolve a ultima leitura, se houver.
        [ -r "$WX_CACHE" ] && cat "$WX_CACHE" || echo '{"ok":false}'
        exit 0
    fi
fi

# ---- tempo ----
if fresh "$WX_CACHE" 600; then
    cat "$WX_CACHE"
    exit 0
fi

URL="https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}"
URL="${URL}&current=temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,is_day"
URL="${URL}&daily=temperature_2m_max,temperature_2m_min&timezone=auto&forecast_days=1"

if RAW=$(curl -sS -m 12 "$URL" 2>/dev/null) && [ -n "$RAW" ]; then
    if OUT=$(printf '%s' "$RAW" | CITY="$CITY" python3 -c "
import json, os, sys
d = json.load(sys.stdin)
c = d.get('current') or {}
day = d.get('daily') or {}
def first(k):
    v = day.get(k) or []
    return v[0] if v else None
print(json.dumps({
    'ok': True,
    'city': os.environ.get('CITY') or '',
    'temp': round(c.get('temperature_2m', 0)),
    'feels': round(c.get('apparent_temperature', 0)),
    'humidity': c.get('relative_humidity_2m'),
    'code': c.get('weather_code'),
    'isDay': bool(c.get('is_day')),
    'tmin': round(first('temperature_2m_min') or 0),
    'tmax': round(first('temperature_2m_max') or 0),
}))" 2>/dev/null); then
        printf '%s\n' "$OUT" > "$WX_CACHE"
        printf '%s\n' "$OUT"
        exit 0
    fi
fi

# Falhou a rede: melhor mostrar a ultima leitura conhecida do que "--".
[ -r "$WX_CACHE" ] && cat "$WX_CACHE" || echo '{"ok":false}'
