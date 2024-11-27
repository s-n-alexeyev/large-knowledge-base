2024-11-27  
[Источник](https://github.com/TheR1D/shell_gpt)
```table-of-contents
title: Содержание
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```
## Установка

```bash
pip install shell-gpt
```

По умолчанию ShellGPT использует API OpenAI и модель GPT-4. Вам понадобится ключ API, вы можете сгенерировать его [здесь](https://beta.openai.com/account/api-keys) . Вам будет предложено ввести ключ, который затем будет сохранен в `~/.config/shell_gpt/.sgptrc`. OpenAI API не бесплатен, [можно найти в ценах OpenAI .](https://openai.com/pricing) дополнительную информацию

>[!tip] Совет
>
>Альтернативно вы можете использовать локально размещенные модели с открытым исходным кодом, которые доступны бесплатно. Чтобы использовать локальные модели, вам потребуется запустить собственный сервер LLM, например [Ollama](https://github.com/ollama/ollama) . Чтобы настроить ShellGPT с помощью Ollama, следуйте этому подробному [руководству](https://github.com/TheR1D/shell_gpt/wiki/Ollama) .
>
**❗️Обратите внимание, что ShellGPT не оптимизирован для локальных моделей и может работать не так, как ожидалось.**
## Конфигурация ShellGPT + Ollama

Теперь, когда у нас запущен бэкэнд Ollama, нам нужно настроить ShellGPT для его использования. Для связи с локальными серверами LLM ShellGPT использует [LiteLLM](https://github.com/BerriAI/litellm) . Чтобы установить его, запустите:

```shell
pip install shell-gpt[litellm]
```

Вариант установки для Ollama минуя VENV 

```bash
pip install shell-gpt[litellm] --break-system-packages --no-warn-script-location
```

По умолчанию `sgpt` устанавливается в ~/.local/bin, можно добавить в переменную $PATH этот путь (зависит от оболочки). 
Или скопировать `sgpt` в /usr/bin

```bash
sudo cp ~/.local/bin/sgpt /usr/bin
```

Проверьте, работает ли серверная часть Ollama и доступна ли она (модель qwen2.5-coder:14b должна уже присутствовать):

```shell
sgpt --model ollama/mistral:qwen2.5-coder:14b  "Who are you?"
# -> I'm ShellGPT, your OS and shell assistant...
```

Если вы запускаете ShellGPT впервые, вам будет предложено ввести ключ API OpenAI. Укажите любую **случайную строку** , чтобы пропустить этот шаг (не просто нажимайте Enter с пустым вводом). Если у вас возникла ошибка, вы можете обратиться [за помощью к сообществу](https://github.com/TheR1D/shell_gpt/discussions) ShellGPT .

Теперь нам нужно изменить несколько настроек в `~/.config/shell_gpt/.sgptrc`.  
- Откройте файл в редакторе и измените `DEFAULT_MODEL` со значением `ollama/qwen2.5-coder:14b`. (для примера)
- Также убедитесь, что `OPENAI_USE_FUNCTIONS` установлено на `false` и `USE_LITELLM` установлено на `true`.
 
 Вот и все, теперь вы можете использовать ShellGPT с бэкэндом Ollama.

```shell
sgpt "Hello Ollama"
```
## Использование

**ShellGPT** предназначен для быстрого анализа и получения информации. Это полезно для простых запросов, начиная от технических конфигураций и заканчивая общими знаниями.

```shell
sgpt "What is the fibonacci sequence"
# -> The Fibonacci sequence is a series of numbers where each number ...
```

ShellGPT принимает приглашение как от стандартного ввода, так и от аргумента командной строки. Предпочитаете ли вы передавать ввод через терминал или указывать его напрямую в качестве аргументов, `sgpt` тебя прикрыло. Например, вы можете легко сгенерировать сообщение фиксации git на основе различий:

```shell
git diff | sgpt "Generate git commit message, for my changes"
# -> Added main feature details into README.md
```

Вы можете анализировать журналы из различных источников, передавая их с помощью стандартного ввода вместе с приглашением. Например, мы можем использовать его для быстрого анализа журналов, выявления ошибок и получения предложений по возможным решениям:

```shell
docker logs -n 20 my_app | sgpt "check logs, find errors, provide possible solutions"
```

```
Error Detected: Connection timeout at line 7.
Possible Solution: Check network connectivity and firewall settings.
Error Detected: Memory allocation failed at line 12.
Possible Solution: Consider increasing memory allocation or optimizing application memory usage.
```

Вы также можете использовать все виды операторов перенаправления для передачи ввода:

```shell
sgpt "summarise" < document.txt
# -> The document discusses the impact...
sgpt << EOF
What is the best way to lear Golang?
Provide simple hello world example.
EOF
# -> The best way to learn Golang...
sgpt <<< "What is the best way to learn shell redirects?"
# -> The best way to learn shell redirects is through...
```
### Команды оболочки

Вы когда-нибудь забывали общие команды оболочки, такие как `find`и вам нужно поискать синтаксис в Интернете? С `--shell` или ярлык `-s` вариант, вы можете быстро генерировать и выполнять нужные вам команды прямо в терминале.

```shell
sgpt --shell "find all json files in current folder"
# -> find . -type f -name "*.json"
# -> [E]xecute, [D]escribe, [A]bort: e
```

Shell GPT знает об ОС и `$SHELL` вы используете, он предоставит команду оболочки для конкретной вашей системы. Например, если вы спросите `sgpt` для обновления вашей системы она вернет команду в зависимости от вашей ОС. Вот пример использования macOS:

```shell
sgpt -s "update my system"
# -> sudo softwareupdate -i -a
# -> [E]xecute, [D]escribe, [A]bort: e
```

Тот же запрос при использовании в Ubuntu выдаст другое предложение:

```shell
sgpt -s "update my system"
# -> sudo apt update && sudo apt upgrade -y
# -> [E]xecute, [D]escribe, [A]bort: e
```

Давайте попробуем это с Docker:

```shell
sgpt -s "start nginx container, mount ./index.html"
# -> docker run -d -p 80:80 -v $(pwd)/index.html:/usr/share/nginx/html/index.html nginx
# -> [E]xecute, [D]escribe, [A]bort: e
```

Мы по-прежнему можем использовать каналы для передачи входных данных в `sgpt` и сгенерируйте команды оболочки:

```shell
sgpt -s "POST localhost with" < data.json
# -> curl -X POST -H "Content-Type: application/json" -d '{"a": 1, "b": 2}' http://localhost
# -> [E]xecute, [D]escribe, [A]bort: e
```

Применение дополнительной магии оболочки в нашей командной строке, в этом примере передача имен файлов в `ffmpeg`:

```shell
ls
# -> 1.mp4 2.mp4 3.mp4
sgpt -s "ffmpeg combine $(ls -m) into one video file without audio."
# -> ffmpeg -i 1.mp4 -i 2.mp4 -i 3.mp4 -filter_complex "[0:v] [1:v] [2:v] concat=n=3:v=1 [v]" -map "[v]" out.mp4
# -> [E]xecute, [D]escribe, [A]bort: e
```

Если вы хотите передать сгенерированную команду оболочки с помощью канала, вы можете использовать `--no-interaction` вариант. Это отключит интерактивный режим и выведет сгенерированную команду на стандартный вывод. В этом примере мы используем `pbcopy` чтобы скопировать сгенерированную команду в буфер обмена:

```shell
sgpt -s "find all json files in current folder" --no-interaction | pbcopy
```
### Интеграция с оболочкой

Это **очень удобная функция** , которая позволяет использовать `sgpt` завершения оболочки прямо в вашем терминале, без необходимости вводить `sgpt` с подсказкой и аргументами. Интеграция с оболочкой позволяет использовать ShellGPT с горячими клавишами в вашем терминале, поддерживаемыми оболочками Bash и ZSH. Эта функция ставит `sgpt` завершения непосредственно в буфер терминала (строка ввода), что позволяет немедленно редактировать предлагаемые команды.

Shell_GPT_Integration.mp4

Чтобы установить интеграцию оболочки, запустите `sgpt --install-integration` и перезагрузите терминал, чтобы применить изменения. Это добавит несколько строк в ваш `.bashrc` или `.zshrc` файл. После этого вы можете использовать `Ctrl+l` (по умолчанию) для вызова ShellGPT. Когда вы нажимаете `Ctrl+l` он заменит текущую строку ввода (буфер) предложенной командой. Затем вы можете отредактировать его и просто нажать `Enter` выполнить.
### Генерация кода

С помощью `--code` или `-c` параметр, вы можете специально запросить вывод чистого кода, например:

```shell
sgpt --code "solve fizz buzz problem using python"
```

```python
for i in range(1, 101):
    if i % 3 == 0 and i % 5 == 0:
        print("FizzBuzz")
    elif i % 3 == 0:
        print("Fizz")
    elif i % 5 == 0:
        print("Buzz")
    else:
        print(i)
```

Поскольку это действительный код Python, мы можем перенаправить вывод в файл:

```shell
sgpt --code "solve classic fizz buzz problem using Python" > fizz_buzz.py
python fizz_buzz.py
# 1
# 2
# Fizz
# 4
# Buzz
# ...
```

Мы также можем использовать каналы для передачи ввода:

```shell
cat fizz_buzz.py | sgpt --code "Generate comments for each line of my code"
```

```python
# Loop through numbers 1 to 100
for i in range(1, 101):
    # Check if number is divisible by both 3 and 5
    if i % 3 == 0 and i % 5 == 0:
        # Print "FizzBuzz" if number is divisible by both 3 and 5
        print("FizzBuzz")
    # Check if number is divisible by 3
    elif i % 3 == 0:
        # Print "Fizz" if number is divisible by 3
        print("Fizz")
    # Check if number is divisible by 5
    elif i % 5 == 0:
        # Print "Buzz" if number is divisible by 5
        print("Buzz")
    # If number is not divisible by 3 or 5, print the number itself
    else:
        print(i)
```
### Режим чата

Часто важно сохранить и вспомнить разговор. `sgpt` создает диалоговый диалог при каждом запрошенном завершении LLM. Диалог может развиваться один за другим (режим чата) или интерактивно, в цикле REPL (режим REPL). Оба способа основаны на одном и том же базовом объекте, называемом сеансом чата. Сеанс находится в [настраиваемом](https://github.com/TheR1D/shell_gpt#runtime-configuration-file) `CHAT_CACHE_PATH`.

Чтобы начать разговор, используйте `--chat` параметр, за которым следует уникальное имя сеанса и приглашение.

```shell
sgpt --chat conversation_1 "please remember my favorite number: 4"
# -> I will remember that your favorite number is 4.

sgpt --chat conversation_1 "what would be my favorite number + 4?"
# -> Your favorite number is 4, so if we add 4 to it, the result would be 8.
```

Вы можете использовать сеансы чата, чтобы итеративно улучшать предложения GPT, предоставляя дополнительную информацию. Можно использовать `--code` или `--shell` варианты инициирования `--chat`:

```shell
sgpt --chat conversation_2 --code "make a request to localhost using python"
```

```python
import requests

response = requests.get('http://localhost')
print(response.text)
```

Попросим LLM добавить к нашему запросу кэширование:

```shell
sgpt --chat conversation_2 --code "add caching"
```

```python
import requests
from cachecontrol import CacheControl

sess = requests.session()
cached_sess = CacheControl(sess)

response = cached_sess.get('http://localhost')
print(response.text)
```

То же самое относится и к командам оболочки:

```shell
sgpt --chat conversation_3 --shell "what is in current folder"
# -> ls

sgpt --chat conversation_3 "Sort by name"
# -> ls | sort

sgpt --chat conversation_3 "Concatenate them using FFMPEG"
# -> ffmpeg -i "concat:$(ls | sort | tr '\n' '|')" -codec copy output.mp4

sgpt --chat conversation_3 "Convert the resulting file into an MP3"
# -> ffmpeg -i output.mp4 -vn -acodec libmp3lame -ac 2 -ab 160k -ar 48000 final_output.mp3
```

Чтобы просмотреть все сеансы в любом диалоговом режиме, используйте команду `--list-chats` или `-lc` вариант:

```shell
sgpt --list-chats
# .../shell_gpt/chat_cache/conversation_1  
# .../shell_gpt/chat_cache/conversation_2
```

Чтобы отобразить все сообщения, относящиеся к конкретному разговору, используйте `--show-chat` опция, за которой следует имя сеанса:

```shell
sgpt --show-chat conversation_1
# user: please remember my favorite number: 4
# assistant: I will remember that your favorite number is 4.
# user: what would be my favorite number + 4?
# assistant: Your favorite number is 4, so if we add 4 to it, the result would be 8.
```
### Режим REPL

Существует очень удобный режим REPL (цикл чтения-оценки-печати), который позволяет вам в интерактивном режиме общаться с моделями GPT. Чтобы начать сеанс чата в режиме REPL, используйте команду `--repl` параметр, за которым следует уникальное имя сеанса. Вы также можете использовать «temp» в качестве имени сеанса, чтобы запустить временный сеанс REPL. Обратите внимание, что `--chat` и `--repl` используют один и тот же базовый объект, поэтому вы можете использовать `--chat` чтобы начать сеанс чата, а затем продолжить его с помощью `--repl` чтобы продолжить разговор в режиме REPL.

```
sgpt --repl temp
Entering REPL mode, press Ctrl+C to exit.
>>> What is REPL?
REPL stands for Read-Eval-Print Loop. It is a programming environment ...
>>> How can I use Python with REPL?
To use Python with REPL, you can simply open a terminal or command prompt ...
```

Режим REPL может работать с `--shell` и `--code` options, что делает его очень удобным для интерактивных команд оболочки и генерации кода:

```
sgpt --repl temp --shell
Entering shell REPL mode, type [e] to execute commands or press Ctrl+C to exit.
>>> What is in current folder?
ls
>>> Show file sizes
ls -lh
>>> Sort them by file sizes
ls -lhS
>>> e (enter just e to execute commands, or d to describe them)
```

Чтобы обеспечить многострочное приглашение, используйте тройные кавычки. `"""`:

```
sgpt --repl temp
Entering REPL mode, press Ctrl+C to exit.
>>> """
... Explain following code:
... import random
... print(random.randint(1, 10))
... """
It is a Python script that uses the random module to generate and print a random integer.
```

Вы также можете войти в режим REPL с начальным приглашением, передав его в качестве аргумента или стандартного ввода, или даже обоих:

```shell
sgpt --repl temp < my_app.py
```

```
Entering REPL mode, press Ctrl+C to exit.
──────────────────────────────────── Input ────────────────────────────────────
name = input("What is your name?")
print(f"Hello {name}")
───────────────────────────────────────────────────────────────────────────────
>>> What is this code about?
The snippet of code you've provided is written in Python. It prompts the user...
>>> Follow up questions...
```
### Вызов функции

[Вызовы функций](https://platform.openai.com/docs/guides/function-calling) — это мощная функция, предоставляемая OpenAI. Это позволяет LLM выполнять функции в вашей системе, которые можно использовать для выполнения различных задач. Чтобы установить [функции по умолчанию,](https://github.com/TheR1D/shell_gpt/tree/main/sgpt/llm_functions/) выполните:

```shell
sgpt --install-functions
```

В ShellGPT есть удобный способ определения функций и их использования. Чтобы создать свою пользовательскую функцию, перейдите к `~/.config/shell_gpt/functions` и создайте новый файл .py с именем функции. Внутри этого файла вы можете определить свою функцию, используя следующий синтаксис:

```python
# execute_shell_command.py
import subprocess
from pydantic import Field
from instructor import OpenAISchema


class Function(OpenAISchema):
    """
    Executes a shell command and returns the output (result).
    """
    shell_command: str = Field(..., example="ls -la", descriptions="Shell command to execute.")

    class Config:
        title = "execute_shell_command"

    @classmethod
    def execute(cls, shell_command: str) -> str:
        result = subprocess.run(shell_command.split(), capture_output=True, text=True)
        return f"Exit code: {result.returncode}, Output:\n{result.stdout}"
```

Комментарий к строке документации внутри класса будет передан в OpenAI API в качестве описания функции вместе с `title` описания атрибутов и параметров. `execute` будет вызвана, если LLM решит использовать вашу функцию. В этом случае мы разрешаем LLM выполнять любые команды Shell в нашей системе. Поскольку мы возвращаем вывод команды, LLM сможет проанализировать его и решить, подходит ли он для приглашения. Вот пример того, как функция может быть выполнена LLM:

```shell
sgpt "What are the files in /tmp folder?"
# -> @FunctionCall execute_shell_command(shell_command="ls /tmp")
# -> The /tmp folder contains the following files and directories:
# -> test.txt
# -> test.json
```

Обратите внимание: если по какой-то причине функция (execute_shell_command) вернет ошибку, LLM может попытаться выполнить задачу на основе выходных данных. Допустим, у нас не установлено `jq` в нашей системе, и мы просим LLM проанализировать файл JSON:

```shell
sgpt "parse /tmp/test.json file using jq and return only email value"
# -> @FunctionCall execute_shell_command(shell_command="jq -r '.email' /tmp/test.json")
# -> It appears that jq is not installed on the system. Let me try to install it using brew.
# -> @FunctionCall execute_shell_command(shell_command="brew install jq")
# -> jq has been successfully installed. Let me try to parse the file again.
# -> @FunctionCall execute_shell_command(shell_command="jq -r '.email' /tmp/test.json")
# -> The email value in /tmp/test.json is johndoe@example.
```

Также возможно объединить несколько вызовов функций в приглашении:

```shell
sgpt "Play music and open hacker news"
# -> @FunctionCall play_music()
# -> @FunctionCall open_url(url="https://news.ycombinator.com")
# -> Music is now playing, and Hacker News has been opened in your browser. Enjoy!
```

Это всего лишь простой пример того, как можно использовать вызовы функций. Это действительно мощная функция, которую можно использовать для выполнения множества сложных задач. У нас есть специальная [категория](https://github.com/TheR1D/shell_gpt/discussions/categories/functions) в обсуждениях GitHub для обмена и обсуждения функций. LLM может выполнять деструктивные команды, поэтому используйте его на свой страх и риск❗️
### Роли

ShellGPT позволяет вам создавать собственные роли, которые можно использовать для генерации кода, команд оболочки или для удовлетворения ваших конкретных потребностей. Чтобы создать новую роль, используйте команду `--create-role` вариант, за которым следует имя роли. Вам будет предложено предоставить описание роли, а также другие сведения. Это создаст файл JSON в `~/.config/shell_gpt/roles` с именем роли. Внутри этого каталога вы также можете редактировать значения по умолчанию. `sgpt` роли, такие как **Shell** , **Code** и **default** . Используйте `--list-roles` возможность вывести список всех доступных ролей и `--show-role` возможность отображения сведений о конкретной роли. Вот пример пользовательской роли:

```shell
sgpt --create-role json_generator
# Enter role description: Provide only valid json as response.
sgpt --role json_generator "random: user, password, email, address"
```

{
  "user": "JohnDoe",
  "password": "p@ssw0rd",
  "email": "johndoe@example.com",
  "address": {
    "street": "123 Main St",
    "city": "Anytown",
    "state": "CA",
    "zip": "12345"
  }
}

Если в описании роли есть слова «APPLY MARKDOWN» (с учетом регистра), то чаты будут отображаться с использованием форматирования markdown.
### Запрос кеша

Управление кешем с помощью `--cache` (по умолчанию) и `--no-cache` параметры. Это кэширование применимо ко всем `sgpt` запросы к OpenAI API:

```shell
sgpt "what are the colors of a rainbow"
# -> The colors of a rainbow are red, orange, yellow, green, blue, indigo, and violet.
```

В следующий раз тот же самый запрос мгновенно получит результаты из локального кэша. Обратите внимание, что `sgpt "what are the colors of a rainbow" --temperature 0.5` сделаю новый запрос, так как мы не предоставили `--temperature` (то же самое относится и к `--top-probability`) по предыдущему запросу.

Это всего лишь несколько примеров того, что мы можем сделать с помощью моделей OpenAI GPT. Я уверен, что вы найдете это полезным для ваших конкретных случаев использования.
### Файл конфигурации

Вы можете настроить некоторые параметры в файле конфигурации времени выполнения. `~/.config/shell_gpt/.sgptrc`:

```
# API ключ, также можно определить OPENAI_API_KEY через переменную окружения.
OPENAI_API_KEY=your_api_key

# Базовый URL сервера бэкенда. Если задано значение "default", URL будет разрешен на основе --model.
API_BASE_URL=default

# Максимальное количество кэшированных сообщений в сессии чата.
CHAT_CACHE_LENGTH=100

# Папка для кэша чата.
CHAT_CACHE_PATH=/tmp/shell_gpt/chat_cache

# Длина кэша запросов (количество).
CACHE_LENGTH=100

# Папка для кэша запросов.
CACHE_PATH=/tmp/shell_gpt/cache

# Время ожидания ответа в секундах.
REQUEST_TIMEOUT=60

# По умолчанию используемая модель OpenAI.
DEFAULT_MODEL=gpt-4o

# Цвет по умолчанию для завершений шелла и кода.
DEFAULT_COLOR=magenta

# При работе в режиме --shell, значение по умолчанию "Y" при отсутствии ввода.
DEFAULT_EXECUTE_SHELL_CMD=false

# Отключить потоковый вывод ответов.
DISABLE_STREAMING=false

# Тема для просмотра markdown (по умолчанию/описание роли).
CODE_THEME=default

# Путь к каталогу с функциями.
OPENAI_FUNCTIONS_PATH=/Users/user/.config/shell_gpt/functions

# Показывать вывод функций, когда LLM их использует.
SHOW_FUNCTIONS_OUTPUT=false

# Разрешить LLM использовать функции.
OPENAI_USE_FUNCTIONS=true

# Принудительно использовать LiteLLM (для локальных моделей LLM).
USE_LITELLM=false
```

Возможные варианты `DEFAULT_COLOR`: черный, красный, зеленый, желтый, синий, пурпурный, голубой, белый, ярко-черный, ярко-красный, ярко-зеленый, ярко-желтый, ярко-синий, ярко-пурпурный, ярко-голубой, ярко-белый. Возможные варианты `CODE_THEME`: [https://pygments.org/styles/](https://pygments.org/styles/)
### Полный список аргументов

```
╭─ Arguments ──────────────────────────────────────────────────────────────────────────────────────────────╮
│   prompt      [PROMPT]  The prompt to generate completions for.                                          │
╰──────────────────────────────────────────────────────────────────────────────────────────────────────────╯
╭─ Options ────────────────────────────────────────────────────────────────────────────────────────────────╮
│ --model            TEXT                       Large language model to use. [default: gpt-4o]             │
│ --temperature      FLOAT RANGE [0.0<=x<=2.0]  Randomness of generated output. [default: 0.0]             │
│ --top-p            FLOAT RANGE [0.0<=x<=1.0]  Limits highest probable tokens (words). [default: 1.0]     │
│ --md             --no-md                      Prettify markdown output. [default: md]                    │
│ --editor                                      Open $EDITOR to provide a prompt. [default: no-editor]     │
│ --cache                                       Cache completion results. [default: cache]                 │
│ --version                                     Show version.                                              │
│ --help                                        Show this message and exit.                                │
╰──────────────────────────────────────────────────────────────────────────────────────────────────────────╯
╭─ Assistance Options ─────────────────────────────────────────────────────────────────────────────────────╮
│ --shell           -s                      Generate and execute shell commands.                           │
│ --interaction         --no-interaction    Interactive mode for --shell option. [default: interaction]    │
│ --describe-shell  -d                      Describe a shell command.                                      │
│ --code            -c                      Generate only code.                                            │
│ --functions           --no-functions      Allow function calls. [default: functions]                     │
╰──────────────────────────────────────────────────────────────────────────────────────────────────────────╯
╭─ Chat Options ───────────────────────────────────────────────────────────────────────────────────────────╮
│ --chat                 TEXT  Follow conversation with id, use "temp" for quick session. [default: None]  │
│ --repl                 TEXT  Start a REPL (Read–eval–print loop) session. [default: None]                │
│ --show-chat            TEXT  Show all messages from provided chat id. [default: None]                    │
│ --list-chats  -lc            List all existing chat ids.                                                 │
╰──────────────────────────────────────────────────────────────────────────────────────────────────────────╯
╭─ Role Options ───────────────────────────────────────────────────────────────────────────────────────────╮
│ --role                  TEXT  System role for GPT model. [default: None]                                 │
│ --create-role           TEXT  Create role. [default: None]                                               │
│ --show-role             TEXT  Show role. [default: None]                                                 │
│ --list-roles   -lr            List roles.                                                                │
╰──────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```
## Docker

Запустите контейнер с помощью `OPENAI_API_KEY` переменная среды и том Docker для хранения кеша. Рассмотрите возможность установки переменных среды `OS_NAME` и `SHELL_NAME` согласно вашим предпочтениям.

```shell
docker run --rm \
           --env OPENAI_API_KEY=api_key \
           --env OS_NAME=$(uname -s) \
           --env SHELL_NAME=$(echo $SHELL) \
           --volume gpt-cache:/tmp/shell_gpt \
       ghcr.io/ther1d/shell_gpt -s "update my system"
```

Пример разговора с использованием псевдонима и `OPENAI_API_KEY` переменная среды:

```shell
alias sgpt="docker run --rm --volume gpt-cache:/tmp/shell_gpt --env OPENAI_API_KEY --env OS_NAME=$(uname -s) --env SHELL_NAME=$(echo $SHELL) ghcr.io/ther1d/shell_gpt"
export OPENAI_API_KEY="your OPENAI API key"
sgpt --chat rainbow "what are the colors of a rainbow"
sgpt --chat rainbow "inverse the list of your last answer"
sgpt --chat rainbow "translate your last answer in french"
```

Вы также можете использовать предоставленный `Dockerfile` для создания собственного имиджа:

```shell
docker build -t sgpt .
```
### Docker + Ollama

Если вы хотите отправлять запросы на экземпляр Ollama и запускать ShellGPT внутри контейнера Docker, вам необходимо настроить Dockerfile и собрать контейнер самостоятельно: необходим пакет Litellm и правильно установлены переменные env.

Пример файла Docker:

```
FROM python:3-slim

ENV DEFAULT_MODEL=ollama/mistral:7b-instruct-v0.2-q4_K_M
ENV API_BASE_URL=http://10.10.10.10:11434
ENV USE_LITELLM=true
ENV OPENAI_API_KEY=bad_key
ENV SHELL_INTERACTION=false
ENV PRETTIFY_MARKDOWN=false
ENV OS_NAME="Arch Linux"
ENV SHELL_NAME=auto

WORKDIR /app
COPY . /app

RUN apt-get update && apt-get install -y gcc
RUN pip install --no-cache /app[litellm] && mkdir -p /tmp/shell_gpt

VOLUME /tmp/shell_gpt

ENTRYPOINT ["sgpt"]
```
## Дополнительная документация

- [Интеграция с Azure](https://github.com/TheR1D/shell_gpt/wiki/Azure)
- [Интеграция Ollama](https://github.com/TheR1D/shell_gpt/wiki/Ollama)