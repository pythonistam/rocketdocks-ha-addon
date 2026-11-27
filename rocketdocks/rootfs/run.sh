#!/usr/bin/with-contenv bashio
# RocketDocks: обратный прокси Ingress -> веб-сервис RocketDocks на компьютере.
# Ключ доступа добавляется заголовком X-Api-Key здесь, в браузер он не попадает.
set -e

HOST="$(bashio::config 'host')"
PORT="$(bashio::config 'port')"
KEY="$(bashio::config 'key')"
KEY="${KEY,,}"   # RocketDocks хранит ключ строчными
THEME="$(bashio::config 'theme')"
SIZE="$(bashio::config 'size')"
LABELS=0
bashio::config.true 'labels' && LABELS=1

if [[ -z "${HOST}" ]]; then
    bashio::exit.nok "Укажите адрес компьютера (host), например 192.168.31.50"
fi
if ! [[ "${HOST}" =~ ^[A-Za-z0-9.-]+$ ]]; then
    bashio::exit.nok "host: только IP-адрес или имя компьютера без http:// и порта"
fi
# Ключ RocketDocks — 32 hex-символа (Настройка панели -> Веб-панель). Неверный ключ сервер
# считает подбором и после 20 ошибок блокирует адрес Home Assistant на 10 минут,
# поэтому формат проверяем до первого запроса.
if ! [[ "${KEY}" =~ ^[A-Fa-f0-9]{32}$ ]]; then
    bashio::exit.nok "key: скопируйте ключ из RocketDocks (Настройка панели -> Веб-панель), 32 символа 0-9 a-f"
fi

UPSTREAM="http://${HOST}:${PORT}"
PAGE_ARGS="theme=${THEME}&labels=${LABELS}"
if [[ "${SIZE}" -gt 0 ]]; then
    PAGE_ARGS="${PAGE_ARGS}&size=${SIZE}"
fi

bashio::log.info "RocketDocks: ${UPSTREAM}"
# Одна проверка при старте (не в цикле — см. блокировку за неверный ключ).
CODE="$(curl -s -o /dev/null -m 5 -w '%{http_code}' -H "X-Api-Key: ${KEY}" "${UPSTREAM}/api/state" || true)"
case "${CODE}" in
    200) bashio::log.info "Компьютер отвечает, ключ принят" ;;
    401) bashio::exit.nok "RocketDocks отклонил ключ (401). Проверьте key в настройках аддона" ;;
    429) bashio::log.warning "RocketDocks временно заблокировал адрес за неверный ключ (429), подождите 10 минут" ;;
    000) bashio::log.warning "Компьютер ${HOST}:${PORT} не отвечает. Включите веб-панель в RocketDocks и разрешите её в брандмауэре; прокси всё равно запущен" ;;
    *)   bashio::log.warning "RocketDocks ответил кодом ${CODE}" ;;
esac

CONF="$(cat /etc/nginx/rocketdocks.conf.tpl)"
# Замена в кавычках: символ & в значении остаётся буквальным.
CONF="${CONF//@UPSTREAM@/"${UPSTREAM}"}"
CONF="${CONF//@KEY@/"${KEY}"}"
CONF="${CONF//@PAGE_ARGS@/"${PAGE_ARGS}"}"
printf '%s\n' "${CONF}" > /etc/nginx/nginx.conf

exec nginx -g 'daemon off;'
