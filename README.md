# HW3 — Docker. Bash

Проект генерирует CSV-данные (товары в магазине) и строит HTML-отчёт с помощью двух Docker-контейнеров.

## Структура

```
.
├── generator/
│   ├── Dockerfile
│   └── generate.py
├── reporter/
│   ├── Dockerfile
│   ├── report.js
│   └── package.json
├── data/            # сюда пишут и читают контейнеры (монтируется как volume)
├── local_data/      # для локальной отладки generate.py
├── run.sh
└── README.md
```

## Команды

```bash
./run.sh build_generator    # собрать образ генератора
./run.sh run_generator      # запустить генератор → data/data.csv
./run.sh create_local_data  # запустить generate.py локально → local_data/data.csv

./run.sh build_reporter     # собрать образ аналитика
./run.sh run_reporter       # запустить аналитик → data/report.html

./run.sh structure          # вывести структуру проекта
./run.sh clear_data         # удалить *.csv и *.html из data/

./run.sh inside_generator   # показать содержимое /data изнутри контейнера генератора
./run.sh inside_reporter    # показать содержимое /data изнутри контейнера аналитика

./run.sh report_server      # запустить nginx-контейнер, раздающий report.html
```

## Как работает монтирование томов

Оба контейнера запускаются с флагом `-v "$(pwd)/data:/data"`.  
Это монтирует локальную папку `data/` хоста в `/data` внутри контейнера, поэтому:
- генератор пишет `data.csv` на хост через `/data/data.csv`,
- аналитик читает `data.csv` с хоста и пишет `report.html` туда же.

Данные **не хранятся внутри контейнеров** — они живут на хосте.

---

## Веб-сервер в GitHub Codespaces (задание для терминаторов)

### Цепочка

```
браузер на компьютере
    ↕  HTTPS (Codespaces port forwarding)
GitHub Codespaces (хост Codespaces)
    ↕  порт 8080 проброшен флагом -p 8080:80
nginx-контейнер (порт 80 внутри Docker-сети)
    ↕  volume mount  -v data:/usr/share/nginx/html
файл report.html на диске Codespaces
```

### Шаги

1. Убедитесь, что `report.html` уже сгенерирован:

   ```bash
   ./run.sh build_generator && ./run.sh run_generator
   ./run.sh build_reporter  && ./run.sh run_reporter
   ```

2. Запустите веб-сервер:

   ```bash
   ./run.sh report_server
   ```

   Команда запускает контейнер `nginx:alpine` в фоне (`-d`) и пробрасывает порт:
   `хост Codespaces :8080` → `контейнер :80`.

3. Откройте вкладку **Ports** в VS Code (Codespaces).  
   Там появится строка с портом **8080** и кнопкой **Open in Browser** — нажмите её.  
   GitHub Codespaces автоматически создаёт публичный HTTPS-адрес вида  
   `https://<codespace-name>-8080.app.github.dev` и проксирует трафик на порт 8080 хоста.

4. В открывшемся браузере перейдите по пути `/report.html`:

   ```
   https://<codespace-name>-8080.app.github.dev/report.html
   ```

