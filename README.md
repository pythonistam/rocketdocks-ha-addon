# RocketDocks — аддон Home Assistant

Репозиторий аддонов Home Assistant с одним аддоном **RocketDocks**: панель программы
RocketDocks с Windows-компьютера в боковом меню HA (Ingress), с управлением щелчками.

Установка: **Настройки -> Дополнения -> Магазин дополнений -> ⋮ -> Репозитории** ->
добавить `https://github.com/pythonistam/rocketdocks-ha-addon` -> установить **RocketDocks**.

Подробности — [rocketdocks/DOCS.md](rocketdocks/DOCS.md).

## Обновления

Каждый push в `main`, меняющий `rocketdocks/`, запускает `.github/workflows/release.yml`: версия в
`rocketdocks/config.yaml` повышается (patch), в `CHANGELOG.md` добавляется запись, ставится тег `vX.Y.Z`.
Home Assistant видит новую версию и предлагает обновление; при включённом автообновлении ставит его сам.
Бот коммитит в `main`, поэтому перед своей правкой делайте `git pull`.
