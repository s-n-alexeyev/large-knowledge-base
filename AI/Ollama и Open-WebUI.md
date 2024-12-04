>Установка/обновление ollama
```bash
sudo curl -fsSL https://ollama.com/install.sh | sh
```


```
/etc/systemd/system/ollama.service
```

```
[Unit]  
Description=Ollama Service  
After=network-online.target  
  
[Service]  
ExecStart=/usr/local/bin/ollama serve  
User=user  
Group=user  
Restart=always  
RestartSec=3  
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/bin"  
  
[Install]  
WantedBy=default.target
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

>Демон для pen Web UI Service
```bash
sudo nano /etc/systemd/system/open-webui.service
```

```
[Unit]
Description=Open Web UI Service
After=network.target

[Service]
User=user
WorkingDirectory=/opt/open-webui-env/bin
ExecStart=/bin/bash -lc "source /opt/open-webui-env/bin/activate && open-webui serve"
Restart=always

[Install]
WantedBy=multi-user.target
```


>Перенос VENV замена содержимого скриптов в bin
```bash
find /opt/open-webui-env/bin -type f -exec sed -i 's|#!/home/user/.venv/open-webui-env/bin/python3.11|#!/usr/bin/env python3|' {} +
```

>Обновление open-webui
```bash
source /opt/open-webui-env/bin/activate  
pip install --upgrade open-webui
```

[Модели Ollama](https://ollama.com/search)
