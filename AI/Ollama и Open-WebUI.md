>Установка ollama
```bash
sudo curl -fsSL https://ollama.com/install.sh | sh
```

>Установка open-webui окружения и его активация
```bash
python3 -m venv /opt/open-webui-env
source /opt/open-webui-env/bin/activate
pip install open-webui
```

>Скрипт для запуска Ollama и Open WebUI
```bash
sh -c 'source /opt/open-webui-env/bin/activate && { ollama serve & ollama_pid=$!; open-webui serve; wait $ollama_pid; } && xdg-open http://0.0.0.0:8080/'
```

>Перенос VENV замена содержимого скриптов в bin
```bash
find /opt/open-webui-env/bin -type f -exec sed -i 's|#!/home/user/.venv/open-webui-env/bin/python3.11|#!/usr/bin/env python3|' {} +
```

>Обновление open-webui
```bash
❯ source /opt/open-webui-env/bin/activate  
❯ pip install --upgrade open-webui
```