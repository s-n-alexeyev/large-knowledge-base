```bash
sh -c 'source ~/.venv/open-webui-env/bin/activate && { ollama serve & ollama_pid=$!; open-webui serve; wait $ollama_pid; } && xdg-open http://0.0.0.0:8080/'
```