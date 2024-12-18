# VPS Security Audit Script

[Источник](https://github.com/Acenotass/vps-audit?tab=readme-ov-file#vps-security-audit-script)

Полноценный скрипт на Bash для аудита безопасности и производительности вашего VPS (Виртуального частного сервера). Этот инструмент проводит различные проверки безопасности и предоставляет подробный отчет с рекомендациями по улучшению.

[![Sample Output](../Media/Pictures/VPS_Security/3451c787ce455a7bd39ceb6174e3de8a_MD5.png)](https://github.com/Acenotass/vps-audit/blob/main/screenshot.png)

## Features

### Проверки безопасности

- Настройка SSH
    - Статус входа под рутом
    - Авторизация по паролю
    - Использование нестандартного порта
- Статус файрвола (UFW)
- Конфигурация Fail2ban
- Неудачные попытки входа в систему
- Статус обновлений системы
- Анализ запущенных служб
- Детектирование открытых портов
- Настройка журналирования sudo
- Выполнение политики паролей
- Обнаружение файлов SUID

### Мониторинг производительности

- Использование дискового пространства
- Использование памяти
- Использование процессора (CPU)
- Активные соединения в Интернете.

## Требования

- Система на основе Ubuntu/Debian (Linux)
- Права администратора или привилегии sudo
- Основные пакеты (большинство из которых предустановлены):
    - ufw
    - systemd
    - netstat
    - grep
    - awk

## Установка

1. Скачать скрипт:

```shell
wget https://raw.githubusercontent.com/vernu/vps-audit/main/vps-audit.sh
# or
curl -O https://raw.githubusercontent.com/vernu/vps-audit/main/vps-audit.sh
```

2. Сделать скрипт исполняемым:

```shell
chmod +x vps-audit.sh
```

## Использование

Запустите скрипт с правами суперпользователя (sudo).:

```shell
sudo ./vps-audit.sh
```

Скрипт будет...:

1. Выполнять все проверки безопасности.
2. Показывать результаты в реальном времени с цветным кодированием:
    - 🟢 [PASS] - проверка прошла успешно
    - 🟡 [WARN] - потенциальные проблемы обнаружены
    - 🔴 [FAIL] - критические проблемы найдены
3. Создавать подробный журнал: `vps-audit-report-[TIMESTAMP].txt`

## Формат вывода

Скрипт обеспечивает два типа вывода:

1. Real-time console output with color coding:

```
[PASS] SSH Root Login - Root login is properly disabled in SSH configuration
[WARN] SSH Port - Using default port 22 - consider changing to a non-standard port
[FAIL] Firewall Status - UFW firewall is not active - your system is exposed
```

2. A detailed report file containing:
    - All check results
    - Specific recommendations for failed checks
    - System resource usage statistics
    - Timestamp of the audit

## Thresholds

[](https://github.com/Acenotass/vps-audit?tab=readme-ov-file#thresholds)

### Resource Usage Thresholds

[](https://github.com/Acenotass/vps-audit?tab=readme-ov-file#resource-usage-thresholds)

- PASS: < 50% usage
- WARN: 50-80% usage
- FAIL: > 80% usage

### Security Thresholds

[](https://github.com/Acenotass/vps-audit?tab=readme-ov-file#security-thresholds)

- Failed Logins:
    - PASS: < 10 attempts
    - WARN: 10-50 attempts
    - FAIL: > 50 attempts
- Running Services:
    - PASS: < 20 services
    - WARN: 20-40 services
    - FAIL: > 40 services
- Open Ports:
    - PASS: < 10 ports
    - WARN: 10-20 ports
    - FAIL: > 20 ports

## Customization

[](https://github.com/Acenotass/vps-audit?tab=readme-ov-file#customization)

You can modify the thresholds by editing the following variables in the script:

- Resource usage thresholds
- Failed login attempt thresholds
- Service count thresholds
- Open port thresholds

## Best Practices

[](https://github.com/Acenotass/vps-audit?tab=readme-ov-file#best-practices)

1. Run the audit regularly (e.g., weekly) to maintain security
2. Review the generated report thoroughly
3. Address any FAIL status immediately
4. Investigate WARN status during maintenance
5. Keep the script updated with your security policies

## Limitations

[](https://github.com/Acenotass/vps-audit?tab=readme-ov-file#limitations)

- Designed for Debian/Ubuntu-based systems
- Requires root/sudo access
- Some checks may need customization for specific environments
- Not a replacement for professional security audit

## Contributing

[](https://github.com/Acenotass/vps-audit?tab=readme-ov-file#contributing)

Feel free to submit issues and enhancement requests!

## License

[](https://github.com/Acenotass/vps-audit?tab=readme-ov-file#license)

This project is licensed under the MIT License - see the LICENSE file for details.

## Security Notice

[](https://github.com/Acenotass/vps-audit?tab=readme-ov-file#security-notice)

While this script helps identify common security issues, it should not be your only security measure. Always:

- Keep your system updated
- Monitor logs regularly
- Follow security best practices
- Consider professional security audits for critical systems