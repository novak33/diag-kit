# diag-kit 🧰

Набор утилит для быстрой диагностики сетевых и системных инцидентов.

Проект вырос из реальной работы в технической поддержке (финтех, платёжная
система): эти проверки я каждый день делал руками при разборе инцидентов —
теперь они автоматизированы и покрыты тестами.

## Состав

| Файл | Назначение | Статус |
|---|---|---|
| `check_host.sh` | Диагностика хоста: DNS, ICMP, TCP-порт | ✅ готово |
| `tests/test_check_host.py` | Смоук-тесты для check_host.sh | ✅ готово |
| `log_analyzer.py` | Парсинг логов: топ ошибок, группировка | 🚧 в работе |
| `ssl_check.py` | Проверка срока жизни SSL-сертификата | 📝 план |
| `service_check.sh` | Аудит systemd-сервисов | 📝 план |

## Требования

- Linux (проверено на RedOS / Ubuntu 22.04)
- bash 4+
- Python 3.10+ (для тестов)

## Использование

```bash
chmod +x check_host.sh

# Базовые проверки: DNS + ping
./check_host.sh example.com

# С проверкой TCP-порта
./check_host.sh example.com 443
```

Пример вывода:

```
=== Diagnostics for host: example.com ===
[ OK ] DNS: example.com -> 93.184.216.34
[ OK ] PING: host responds to ICMP
[ OK ] PORT: TCP 443 is open
=== Result: host example.com is available ===
```

## Тесты и CI

```bash
pytest -v
```

На каждый push GitHub Actions прогоняет: `shellcheck` для bash-скриптов,
`flake8` + `pytest` для python.

## Коды выхода

- `0` — все критичные проверки прошли
- `1` — DNS не разрешился или TCP-порт закрыт

## Roadmap

- [ ] `log_analyzer.py`: парсинг nginx/syslog, топ ошибок за период
- [ ] `ssl_check.py`: проверка сертификатов с порогом в днях
- [ ] `service_check.sh`: поиск failed systemd-сервисов
- [ ] Вывод отчёта в Telegram
