Monitoring Test Service

Простой Bash-скрипт для мониторинга указанного процесса и проверки HTTPS-доступности сервиса.
Сценарий проверяет состояние процесса каждую минуту, логирует события старта/остановки. 
При активном процесс логирует ошибки сети (конкетного адреса с минутным интервалом).

Структура проекта
monitoring-test/
├── monitoring-test.sh        # основной скрипт
├── monitoring-test.service   # systemd unit
├── monitoring-test.timer     # systemd таймер - вынес отдельно для лучшего мониторинга и системности
└── README.md

Установка
Скопировать скрипт и юниты:
sudo cp monitoring-test.sh /usr/local/bin/
sudo cp monitoring-test.service monitoring-test.timer /etc/systemd/system/

Перезагрузить systemd:
sudo systemctl daemon-reload

Включить и запустить таймер:
sudo systemctl enable --now monitoring-test.timer

Проверка

Запустить тестовый процесс:

ptest 300 & - делал копию процесса sleep на основе /bin/sleep


Проверить логи:
sudo tail -f /var/log/monitoring.log

Удаление
sudo systemctl disable --now monitoring-test.timer
sudo rm -f /etc/systemd/system/monitoring-test.{service,timer}
sudo rm -f /usr/local/bin/monitoring-test.sh /usr/local/bin/ptest
sudo rm -f /var/log/monitoring.log /tmp/ptest_pid

Filkin Boris — DevOps Engineer (2025)