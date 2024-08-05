# Hashcat  - шпаргалка

## Запуск Hashcat

```bash
hashcat [опции]... [хеш] [словарь]...
```

## Основные опции

- `-m, --hash-type`: Указывает тип хеша. Например, `-m 0` для MD5.
- `-a, --attack-mode`: Выбирает режим атаки (0: Словарь, 3: Маскирование и т. д.).
- `-w, --workload-profile`: Устанавливает профиль рабочей нагрузки для оптимизации производительности.
- `-o, --outfile`: Указывает файл для сохранения результатов.
- `-r, --rules-file`: Применяет файл правил к словарю.
- `-j, --skip`: Пропускает указанное количество хешей в словаре.
- `--session`:  Указание сессии для запуска/возобновления. Имя по умолчанию `hashcat` , находится в `~/.local/share/hashcat/sessions/`.
- `--restore`: Возобновляет сеанс из файла восстановления работает в паре с ключом  `--session`.
- `--help`: Полная справка по всем командам
## Словарные атаки

### MD5 хеши

```bash
hashcat -m 0 hashes.txt dictionary.txt
```

### SHA-256 хеши

```bash
hashcat -m 1400 hashes.txt dictionary.txt
```

## Атаки с использованием правил

```bash
hashcat -m 0 -r rules.txt hashes.txt dictionary.txt
```

## Маскирование

### Числовые пароли

```bash
hashcat -a 3 -m 0 hashes.txt ?d?d?d?d
```

### Символьные пароли

```bash
hashcat -a 3 -m 0 hashes.txt ?l?l?l?l?l?l?l?l
```

## Комбинаторные атаки

```bash
hashcat -a 1 -m 0 hashes.txt wordlist1.txt wordlist2.txt
```

## Возобновление сеанса

```bash
hashcat --restore --session session_name
```

## Дополнительные опции

- `-h, --help`: Выводит справку о командах и опциях Hashcat.
- `-V, --version`: Выводит версию Hashcat.
- `-s, --status`: Выводит текущий статус выполнения атаки.
- `-S, --status-timer`: Устанавливает интервал вывода статуса выполнения атаки.
- `-b, --benchmark`: Запускает бенчмарк для оценки производительности.
## Инструменты
`cap2hccapx` это инструмент, который используется для преобразования файлов с захваченным трафиком Wi-Fi в формате `.cap` в формат `.hccapx`, который используется для атак на WPA/WPA2.

1. **Преобразование файла .cap в .hccapx**:
   
```shell
cap2hccapx <input.cap> <output.hccapx>
```

   Этот пример преобразует файл `input.cap` в файл `output.hccapx`.

2. **Преобразование нескольких файлов .cap в .hccapx**:

```shell
cap2hccapx <input1.cap> <output1.hccapx> <input2.cap> <output2.hccapx> ...
```

   Этот пример преобразует несколько файлов `.cap` в соответствующие файлы `.hccapx`.

3. **Преобразование всех файлов .cap в текущем каталоге**:

```shell
for file in *.cap; do cap2hccapx "$file" "${file%.cap}.hccapx"; done
```

Этот пример использует цикл для преобразования всех файлов `.cap` в текущем каталоге в файлы `.hccapx`.

Это основные примеры использования `cap2hccapx` для преобразования файлов захвата Wi-Fi. Пожалуйста, помните, что использование этого инструмента для любых целей, кроме тестирования безопасности вашей собственной сети или с согласия владельца сети, может нарушать законы о защите данных и привести к неприятным последствиям.

# Атака по маске

## Описание

Попробуйте все комбинации из заданного пространства ключей, как при [атаке методом грубой силы](https://hashcat.net/wiki/doku.php?id=brute_force_attack "brute_force_attack") , но более конкретно.

## Преимущество перед грубой силой

Причина, по которой мы делаем это, а не придерживаемся традиционного грубого подхода, заключается в том, что мы хотим **уменьшить** **пространство ключей** -кандидатов на пароль до более эффективного.

Вот единственный пример. Хотим взломать пароль: _Julia1984_

При традиционной атаке методом грубой силы нам требуется набор символов, содержащий все заглавные буквы, все строчные буквы и все цифры (так называемый «миксальфа-цифровой»). Длина пароля равна 9, поэтому нам придется перебрать 62^9 (13.537.086.546.263.552) комбинаций. Допустим, мы взламываем скорость 100 М/с, для этого потребуется более **4 лет** .

В атаке по маске мы знаем о людях и о том, как они создают пароли. Приведенный выше пароль соответствует простому, но распространенному шаблону. К нему добавляются имя и год. Мы также можем настроить атаку так, чтобы использовать заглавные буквы только в первой позиции. Очень редко можно увидеть заглавную букву только во второй или третьей позиции. Короче говоря, с помощью атаки по маске мы можем уменьшить пространство ключей до 52*26*26*26*26*10*10*10*10 (237.627.520.000) комбинаций. При той же скорости взлома в 100 М/с на это уходит всего **40 минут** .

## Недостаток по сравнению с грубой силой

Здесь **ничего нет** . Можно возразить, что приведенный выше пример весьма специфичен, но это не имеет значения. Даже при атаке по маске мы можем настроить маску так, чтобы она использовала то же пространство ключей, что и при атаке методом грубой силы. Дело только в том, что это не может работать наоборот.

Обратите внимание, что маски внутри разделены на две части, чтобы дать hashcat возможность работать в качестве усилителя и преодолевать узкие места PCI-E.

## Маски

Для каждой позиции сгенерированных кандидатов на пароль нам необходимо настроить заполнитель. Если пароль, который мы хотим взломать, имеет длину _8_ , наша маска должна состоять из _8_ заполнителей.

- Маска — это простая **строка** , которая настраивает пространство ключей механизма кандидатов на пароль с помощью заполнителей.
- Заполнителем может быть либо пользовательская переменная набора символов, либо встроенная переменная набора символов, либо статическая буква.
- Переменная обозначается знаком ? буква, за которой следует одно из встроенных кодировок (l, u, d, s, a) или одно из имен переменных пользовательской кодировки (1, 2, 3, 4).
- Статическая буква не обозначается буквой. Исключением является случай, когда нам нужна статическая буква? сам по себе, который должен быть записан как ??.
## Выход

Оптимизированные благодаря частично обратным алгоритмам, кандидаты на пароли генерируются в следующем порядке:

```
aaaaaaaa
aaaabaaa
aaaacaaa
.
.
.
aaaaxzzz
aaaayzzz
aaaazzzz
baaaaaaa
baaabaaa
baaacaaa
.
.
.
baaaxzzz
baaayzzz
baaazzzz
.
.
.
**zzzzzzzz**
```

ПРИМЕЧАНИЕ. Это показывает, что первые четыре буквы увеличиваются первыми и чаще всего. Однако точное число может варьироваться, особенно в меньшем пространстве ключей, но оно фиксируется до тех пор, пока пространство ключей не будет полностью просканировано.

## Встроенные кодировки

- `?l = abcdefghijklmnopqrstuvwxyz`
- `?u = ABCDEFGHIJKLMNOPQRSTUVWXYZ  `
- `?d = 0123456789`
- `?h = 0123456789abcdef`
- `?H = 0123456789ABCDEF`
- `?s = «space»!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~`
- `?a = ?l?u?d?s`
- `?b = 0x00 - 0xff`
## Пользовательские кодировки

Все версии hashcat имеют четыре параметра командной строки для настройки четырех пользовательских кодировок.

```
--custom-charset1=CS
--custom-charset2=CS
--custom-charset3=CS
--custom-charset4=CS
```

Эти параметры командной строки имеют четыре аналоговых ярлыка: -1, -2, -3 и -4. Вы можете указать символы непосредственно в командной строке или использовать так называемый файл набора символов hashcat (обычный текстовый файл с расширением .hcchr, который содержит символы/цифры, которые будут использоваться в первой строке файла). См. примеры ниже:
### Примеры

Все следующие команды определяют один **и тот же** собственный набор символов, состоящий из символов «abcdefghijklmnopqrstuvwxyz0123456789» (также известный как «lalpha-numeric»):

```
-1 abcdefghijklmnopqrstuvwxyz0123456789
-1 abcdefghijklmnopqrstuvwxyz?d
-1 ?l0123456789
-1 ?l?d
-1 loweralpha_numeric.hcchr # file that contains all digits + chars (abcdefghijklmnopqrstuvwxyz0123456789)
```

Следующая команда определяет набор символов, состоящий из символов «0123456789abcdef»:

```
-1 ?dabcdef
```

Следующая команда определяет полный 7-битный набор символов ascii (также известный как «mixalpha-numeric-all-space»):

```
-1 ?l?d?s?u
```

Следующая команда устанавливает первую пользовательскую кодировку (-1) для символов русского языка:

```
-1 charsets/special/Russian/ru_ISO-8859-5-special.hcchr
```
## Маска по умолчанию

Если `-a3` запрашивается без указания маски, используется следующая маска по умолчанию:

```
?1?2?2?2?2?2?2?3?3?3?3?d?d?d?d
```

… где пользовательские наборы символов:

```
1 - ?l?d?u (строчные, цифры и прописные буквы)
2 - ?l?d (строчные буквы и цифры)
3 - ?l?d*!$@_ (строчные буквы, цифры и пять выбранных специальных символов)
```

Эта маска также доступна в виде файла масок в `./masks/`каталоге, например `hashcat-default.hcmask`, .
## Пример

Следующие команды создают следующих кандидатов на пароль:

```
команда: -a3 ?l?l?l?l?l?l?l?l
пространство символов: аааааааа - zzzzzzzz
```

```
команда: -a3 -1 ?l?d ?1?1?1?1?1
пространство символов: ааааа - 99999
```

```
команда: -a3 пароль?d
пространство символов: пароль0 - пароль9
```

```
команда: -a3 -1 ?l?u ?1?l?l?l?l?l19?d?d
пространство символов: аааааа1900 - Zzzzz1999
```

```
команда: -a3 -1 ?dabcdef -2 ?l?u ?1?1?2?2?2?2?2
пространство символов: 00aaaaa - ffZZZZZ
```

```
команда: -a3 -1 efghijklmnop ?1?1?1
пространство символов: eee - ppp
```

## Увеличение длины пароля

Атака по маске всегда зависит от длины целевого пароля. Например, если мы используем маску, `?l?l?l?l?l?l?l?l`мы можем взломать только пароль длиной 8, а если целевой пароль имеет длину 7, эта маска его не найдет. Вот почему нам приходится повторять атаку несколько раз, каждый раз добавляя в маску один заполнитель:

```
?l
?l?l
?l?l?l
?l?l?l?l
?l?l?l?l?l
?l?l?l?l?l?l
?l?l?l?l?l?l?l
?l?l?l?l?l?l?l?l
```

Чтобы автоматизировать это, вы можете использовать `--increment` флаг. Этот флаг будет автоматически использовать только первый заполнитель, затем первые два, затем первые три и т. д. Вы также можете настроить начальную и конечную длину с помощью флагов `--increment-min` и `--increment-max`.

Примечание: длина самой маски также является ограничивающим фактором для hashcat. Маски не будут увеличиваться за пределы своей длины. Например, если длина маски составляет только 4, `--increment` она не будет увеличиваться за пределы длины 4, `--increment-min` длина 5 не будет иметь никакого эффекта и т. д.
## Файлы кодировки Hashcat

Файлы кодировок Hashcat (расширение файла: .hcchr) — это удобный способ повторного использования кодировок, определения пользовательских кодировок и использования кодировок, специфичных для языка, поставляемых hashcat.

Эти файлы можно использовать вместе с параметром --custom-charsetN= (или -1, -2, -3 и -4). Вместо предоставления всей кодировки непосредственно в командной строке поддержка файлов .hcchr позволяет указать путь к файлу:

```
-1 charsets/standard/German/de_cp1252.hcchr
```

Важно, чтобы файлы .hcchr создавались с использованием кодировок файлов, специфичных для языка (например, cp1252, ISO-8859-15 и т. д.). Примеры содержимого и кодировки файлов .hcchr см. в примерах, поставляемых с hashcat (например, `[HASHCATROOT]/charsets/standard/Italian/)`.

Подсказка: используйте iconv и аналогичные инструменты для преобразования файлов в кодировку файла, специфичную для языка (если, например, они созданы как файл UTF-8).
## Файлы масок Hashcat

Файлы масок Hashcat (расширение файла: .hcmask) — это файлы, которые содержат пользовательские кодировки (необязательно) и маски (например, `?1?1?1?1?d?d`) построчно. Преимущество использования файлов .hcmask, которые представляют собой обычные текстовые файлы, заключается в том, что эти файлы позволяют пользователю hashcat иметь набор предопределенных и хорошо работающих масок, хранящихся в файле (или нескольких, например, файлах, специфичных для политики паролей), где строки содержат в файле hcmask можно, например, отсортировать по увеличению времени выполнения и/или вероятности совпадений*.

Общий формат одной строки в файле .hcmask следующий:

```
[?1,][?2,][?3,][?4,]mask
```

где заполнители следующие:

- `[?1]` это значение будет установлено для первой пользовательской кодировки (--custom-charset1 или -1), необязательно
- `[?2]` вторая пользовательская кодировка (--custom-charset2 или -2) будет установлена ​​на это значение, необязательно
- `[?3]` для третьего пользовательского набора символов (--custom-charset3 или -3) будет установлено это значение, необязательно
- `[?4]`  этому значению будет присвоено 4-е пользовательское кодирование (--custom-charset4 или -4), необязательно
- `[mask]` маска, которая должна (но не обязательно) использовать пользовательскую кодировку, определенную `[?1], [?2], [?3]`или `[?4]`, и может использовать любую дополнительную предопределенную кодировку (`?l, ?u, ?d, ?h, ?H, ?s, ?a, ?b`), а также может содержать фиксированные символы (пример значения: `pass?1?d?d?2?l?l`)

Вы предоставляете файл .hcmask именно там, где обычно размещаете одну маску в командной строке, например:

```
-a3 hash.txt mask_file.hcmask
```

Другой менее важный синтаксис доступен в файлах .hcmask:  

- с помощью # вы можете прокомментировать строку (она не будет использоваться), с помощью \# вы можете использовать # в начале строки (либо внутри пользовательских кодировок, либо, если пользовательская кодировка не используется, внутри маски)  
- означает, что запятую следует использовать буквально (а не разделитель между ?1, ?2, ?3, ?4 или маску)  
- `??` внутри маски или пользовательской кодировки означает, что вопросительный знак должен использоваться как буквальный символ (в противном случае, если использовался только один вопросительный знак, он был бы интерпретирован как начало ссылки на пользовательскую кодировку или встроенную кодировку)  
  
Примечания:

- Файлы .hcmask можно использовать вместе с параметром -i (приращение) для режима грубой силы.
- Не допускается, чтобы `[mask]` содержала ссылки `?1,?2,?3`или `?4`, если они не установлены через `[?1], [?2], [?3], [?4]`. Это приведет к появлению сообщения об ошибке. Если вы хотите использовать собственную кодировку для своих масок, вы должны определить ее в той же строке файла hcmask, используя поля `[?1], [?2], [?3], [?4]`.  
- Если, например, `[?2]` не было установлено, поскольку в этом нет необходимости, запятую, которая обычно следует за `[?2]`, также необходимо опустить. См. примеры ниже.
### Пример

Следующий файл .hcmask содержит несколько допустимых строк примеров, показывающих, как использовать эту функцию:

```
?d?l,test?1?1?1
abcdef,0123,ABC,789,?3?3?3?1?1?1?1?2?2?4?4?4?4
company?d?d?d?d?d
?l?l?l?l?d?d?d?d?d?d
?u?l,?s?d,?1?a?a?a?a?2
```

Примечание. Также см. [Часто задаваемые вопросы: Что такое файл маски hashcat?](https://hashcat.net/wiki/doku.php?id=frequently_asked_questions#what_is_a_hashcat_mask_file "Часто задаваемые вопросы")

## Список всех параметров
|  Короткая / Длинная опция      | Тип  | Описание                                             | Пример |  
|---|---|---|---|  
|  -m, --hash-type               | Числ | Тип хеша, смотри описание ниже                       | -m 1000 |  
|  -a, --attack-mode             | Числ | Режим атаки, смотри описание ниже                    | -a 3 |  
|  -V, --version                 |      | Напечатать версию                                    |  |  
|  -h, --help                    |      | Напечатать справку                                   |  |  
|      --quiet                   |      | Подавать вывод                                       |  |  
|      --hex-charset             |      | Подразумевать, что символ дан в hex                  |  |  
|      --hex-salt                |      | Подразумевать, что соль дана в hex                   |  |  
|      --hex-wordlist            |      | Подразрумевать, что список слов дан в hex            |  |  
|      --force                   |      | Игнорировать предупреждения                          |  |  
|      --deprecated-check-disable|      | Включает устаревшие плагины                          |  |  
|      --status                  |      | Включить автоматическое обновление экрана статуса    |  |  
|      --status-json             |      | Включает формат JSON для статуса вывода              |  |  
|      --status-timer            | Числ | Установить секунды между обн-нием экрана статуса на X| --status-timer=1 |  
|      --stdin-timeout-abort     | Числ | Прервать если нет ввода из stdin в течении X секунд  | --stdin-timeout-abort=300 |  
|      --machine-readable        |      | Показывать вид статуса в машинном формате            |  |  
|      --keep-guessing           |      | Продолжать разгадывать хеш после его взлома          |  |  
|      --self-test-disable       |      | Отключить функцию самотестирования при запуске       |  |  
|      --loopback                |      | Добавить новые пароли в induct директорию            |  |  
|      --markov-hcstat           | Файл | Указать hcstat файл для использования                | --markov-hc=my.hcstat |  
|      --markov-disable          |      | Отключить цепи Маркова, эмулировать классич.брут-форс| |  
|      --markov-classic          |      | Включить классические цепи Марковаs, без на-позицию  |  |  
|  -t, --markov-threshold        | Числ | Предел X при кот. остан-тся принятие нов.цеп.Маркова | -t 50 |  
|      --runtime                 | Числ | Остановить сессию после X секунд работы              | --runtime=10 |  
|      --session                 | Стр  | Указать имя сессии                                   | --session=mysession |  
|      --restore                 |      | Восстановить сессию из --session                     |  |  
|      --restore-disable         |      | Не записывать файл восстановления                    |  |  
|      --restore-file-path       | Файл | Указать путь до файла восстановления                 | --restore-file-path=my.restore |  
|  -o, --outfile                 | Файл | Указать файл вывода для раскрытых хешей              | -o outfile.txt |  
|      --outfile-format          | Числ | Указать формат вывода X для раскрытых хешей          | --outfile-format=7 |  
|      --outfile-autohex-disable |      | Отключить использование $HEX[] в выводе паролей      |  |  
|      --outfile-check-timer     | Числ | Установить секунды между проверкой файла вывода на X | --outfile-check=30 |  
|      --wordlist-autohex-disable|      | Отключить преобразование $HEX[] из словаря           |  |  
|  -p, --separator               | Симв | Символ-разделитесь для списка хешей и файла вывода   | -p : |  
|      --stdout                  |      | Не взламывать хеш, только показать кандидаты в пароли| |  
|      --show                    |      | Сравнить список хешей с potfile; Показать взломанные |  |  
|      --left                    |      | Сравнить список хешей с potfile;Показать невзломанные| |  
|      --username                |      | Включить игронирование имён польз. в файле хешей     |  |  
|      --remove                  |      | Включить удаление хешей после взлома                 |  |  
|      --remove-timer            | Числ | Обновлять файл ввода хешей каждые X секунд           | --remove-timer=30 |  
|      --potfile-disable         |      | Не писать в potfile                                  |  |  
|      --potfile-path            | Дир  | Указать путь до potfile                              | --potfile-path=my.pot |  
|      --encoding-from           |Кодир.| Принудительная внутренняя кодировка на X             | --encoding-from=iso-8859-15 |  
|      --encoding-to             |Кодир.| Принудительная внутренняя кодировка на X             | --encoding-to=utf-32le |  
|      --debug-mode              | Числ | Задать режим отл. (только гибридный с помощью правил)| --debug-mode=4 |  
|      --debug-file              | Файл | Файл вывода для отладочных правил                    | --debug-file=good.log |  
|      --induction-dir           | Дир  | Указать induction дир-ию для использования loopback  | --induction=inducts |  
|      --outfile-check-dir       | Дир  | Ук-ть дир-ию файла вывода для слеж. за раскр.паролями| --outfile-check-dir=x |  
|      --logfile-disable         |      | Отключить файл журнала                               |  |  
|      --hccapx-message-pair     | Числ | Загружать только пары сообщений из hccapx соответ. X | --hccapx-message-pair=2 |  
|      --nonce-error-corrections | Числ | The BF size range to replace AP's nonce last bytes   | --nonce-error-corrections=16 |  
|      --keyboard-layout-mapping | Файл | Сопоставление раскладки клав-ры для спец. реж. хеша  | --keyb=german.hckmap |  
|      --truecrypt-keyfiles      | Файл | Используемые файлы ключей, разделены запятыми        | --truecrypt-key=x.png |  
|      --veracrypt-keyfiles      | Файл | Используемые файлы ключей, разделены запятыми        | --veracrypt-key=x.txt |  
|      --veracrypt-pim-start     | Числ | VeraCrypt personal iterations multiplier start       | --veracrypt-pim-start=450 |  
|      --veracrypt-pim-stop      | Числ | VeraCrypt personal iterations multiplier stop        | --veracrypt-pim-stop=500 |  
|  -b, --benchmark               |      | Запустить бенчмарк                                   |  |  
|      --benchmark-all           |      | Запустить бенчмарк всех хеш-режимов (требует -b)     |  |  
|      --speed-only              |      | Только показать ожидаемую скорость атаки и выйти     |  |  
|      --progress-only           |      | Возвращает размер шага опт. прогресса и время обра-ки| |  
|  -c, --segment-size            | Числ | Установить размер в MB для кэширования словаря на X  | -c 32 |  
|      --bitmap-min              | Числ | Уст. мин. бит, позв. для для битовых массивов на X   | --bitmap-min=24 |  
|      --bitmap-max              | Числ | Уст. макс. бит, позв. для для битовых массивов на X  | --bitmap-min=24 |  
|      --cpu-affinity            | Стр  | Использовать CPU устройства, разделены запятой       | --cpu-affinity=1,2,3 |  
|      --hook-threads            | Числ | Устанавливает число потоков для хука (на вычислительный юнит) | --hook-threads=8 |  
|      --hash-info               |      | Показывает информацию для каждого хеш-режима         |  |  
|      --example-hashes          |      | Псевдоним для --hash-info                            |  |  
|      --backend-ignore-cuda     |      | При запуске не пытаться открыть интерфейс CUDA       |  |  
|      --backend-ignore-opencl   |      | При запуске не пытаться открыть интерфейс OpenCL     |  |  
|  -I, --backend-info            |      | Показать информацию об обнаруж-х конечных API устр-х | -I |  
|  -d, --backend-devices         | Стр  | Конечные устройства для исполь-я, разделены запятыми | -d 1 |  
|  -D, --opencl-device-types     | Стр  | OpenCL типы устр. для использ., разделить запятой    | -D 1 |  
|  -O, --optimized-kernel-enable |      | Включить оптимизированные ядра (ограничение длины пароля)| |  
|  -w, --workload-profile        | Числ | Задействовать указанный профиль работы, варианты ниже| -w 3 |  
|  -n, --kernel-accel            | Числ | Ручная подстройка,установить шаг внешнего цикла на X | -n 64 |  
|  -u, --kernel-loops            | Числ | Ручная подстройка,установить шаг внутр. цикла на X   | -u 256 |  
|  -T, --kernel-threads          | Числ | Ручная настройка рабочей нагрузки, уст. счёт. потоков на X        | -T 64 |  
|      --backend-vector-width    | Числ | Вручную перезаписанная ширина вектора на X           | --backend-vector=4 |  
|      --spin-damp               | Числ | Использовать CPU для синхр. устройств, в процентах   | --spin-damp=50 |  
|      --hwmon-disable           |      | Откл. считывание температуры и вращ. вент. и тригеры |  |  
|      --hwmon-temp-abort        | Числ | Остановить, если темп. дост. X градусов Цельсия      | --hwmon-temp-abort=100 |  
|      --scrypt-tmto             | Числ | Внуччную перезаписать значение TMTO для scrypt на X  | --scrypt-tmto=3 |  
|  -s, --skip                    | Числ | Пропустить X слов от начала                          | -s 1000000 |  
|  -l, --limit                   | Числ | Лимит X слов от начала + пропущенные слова           | -l 1000000 |  
|      --keyspace                |      | Показать значения простр.ключей base:mod и выйти     |  |  
|  -j, --rule-left               | Прав | Единичное правило прим-ся к кажд.слову из лев.словаря| -j 'c' |  
|  -k, --rule-right              | Прав | Единич. правило прим-ся к кажд.слову из прав.словаря | -k '^-' |  
|  -r, --rules-file              | Файл | Неск. правил применяется к каждому слову из словаря  | -r rules/best64.rule |  
|  -g, --generate-rules          | Числ | Сгенерировать X случайных правил                     | -g 10000 |  
|      --generate-rules-func-min | Числ | Принудительно мин. X функц. на правило               |  |  
|      --generate-rules-func-max | Числ | Принудительно макс. X функц. на правило              |  |  
|      --generate-rules-func-sel | Стр  | Пул операторов, из которых генератору случайных правил разрешено выбирать  | --generate-rules-func-sel=ioTlc |  
|      --generate-rules-seed     | Числ | Установить источник генератора случайных чисел на X  |  |  
|  -1, --custom-charset1         | НС   | Пользовательский набор символов ?1                   | -1 ?l?d?u |  
|  -2, --custom-charset2         | НС   | Пользовательский набор символов ?2                   | -2 ?l?d?s |  
|  -3, --custom-charset3         | НС   | Пользовательский набор символов ?3                   |  |  
|  -4, --custom-charset4         | НС   | Пользовательский набор символов ?4                   |  |  
|      --identify                |      | Показывает все поддерживаемые алгоритмы для хешей    | --identify my.hash |  
|  -i, --increment               |      | Включить режим приращения маски                      |  |  
|      --increment-min           | Числ | Начать прирост маски на X                            | --increment-min=4 |  
|      --increment-max           | Числ | Остановить прирост маски на X                        | --increment-max=8 |  
|  -S, --slow-candidates         |      | Включить медленный (но продвинутый) ген-ор кандидатов| |  
|      --brain-server            |      | Включить brain сервер                                |  |  
|      --brain-server-timer      | Числ | Обновлять дамп brain server каждые X секунд (мин:60) | --brain-server-timer=300 |  
|  -z, --brain-client            |      | Включить brain клиент, активирует -S                 |  |  
|      --brain-client-features   | Числ | Определить функции клиента brain, смотри ниже        | --brain-client-features=3 |  
|      --brain-host              | Стр  | Хост сервера Brain (IP или домен)                    | --brain-host=127.0.0.1 |  
|      --brain-port              | Порт | Порт сервера Brain                                   | --brain-port=13743 |  
|      --brain-password          | Стр  | Пароль аутентификации на сервере Brain               | --brain-password=bZfhCvGUSjRq |  
|      --brain-session           | Шестн| Перезаписать автоматически рассчитанную серссию brain| --brain-session=0x2ae611db |  
|      --brain-session-whitelist | Шестн| Разрешить только заданные сессии, разделены запятыми | --brain-session-whitelist=0x2ae611db |
## Таблица для -m параметра
| # | Name | Category |
| ---- | ---- | ---- |
| 900 | `MD4` | Raw Hash |
| 0 | `MD5` | Raw Hash |
| 100 | `SHA1` | Raw Hash |
| 1300 | `SHA2-224` | Raw Hash |
| 1400 | `SHA2-256` | Raw Hash |
| 10800 | `SHA2-384` | Raw Hash |
| 1700 | `SHA2-512` | Raw Hash |
| 17300 | `SHA3-224` | Raw Hash |
| 17400 | `SHA3-256` | Raw Hash |
| 17500 | `SHA3-384` | Raw Hash |
| 17600 | `SHA3-512` | Raw Hash |
| 6000 | `RIPEMD-160` | Raw Hash |
| 600 | `BLAKE2b-512` | Raw Hash |
| 11700 | `GOST R 34.11-2012 (Streebog) 256-bit, big-endian` | Raw Hash |
| 11800 | `GOST R 34.11-2012 (Streebog) 512-bit, big-endian` | Raw Hash |
| 6900 | `GOST R 34.11-94` | Raw Hash |
| 17010 | `GPG (AES-128/AES-256 (SHA-1($pass)))` | Raw Hash |
| 5100 | `Half MD5` | Raw Hash |
| 17700 | `Keccak-224` | Raw Hash |
| 17800 | `Keccak-256` | Raw Hash |
| 17900 | `Keccak-384` | Raw Hash |
| 18000 | `Keccak-512` | Raw Hash |
| 6100 | `Whirlpool` | Raw Hash |
| 10100 | `SipHash` | Raw Hash |
| 70 | `md5(utf16le($pass))` | Raw Hash |
| 170 | `sha1(utf16le($pass))` | Raw Hash |
| 1470 | `sha256(utf16le($pass))` | Raw Hash |
| 10870 | `sha384(utf16le($pass))` | Raw Hash |
| 1770 | `sha512(utf16le($pass))` | Raw Hash |
| 610 | `BLAKE2b-512($pass.$salt)` | Raw Hash salted and/or iterated |
| 620 | `BLAKE2b-512($salt.$pass)` | Raw Hash salted and/or iterated |
| 10 | `md5($pass.$salt)` | Raw Hash salted and/or iterated |
| 20 | `md5($salt.$pass)` | Raw Hash salted and/or iterated |
| 3800 | `md5($salt.$pass.$salt)` | Raw Hash salted and/or iterated |
| 3710 | `md5($salt.md5($pass))` | Raw Hash salted and/or iterated |
| 4110 | `md5($salt.md5($pass.$salt))` | Raw Hash salted and/or iterated |
| 4010 | `md5($salt.md5($salt.$pass))` | Raw Hash salted and/or iterated |
| 21300 | `md5($salt.sha1($salt.$pass))` | Raw Hash salted and/or iterated |
| 40 | `md5($salt.utf16le($pass))` | Raw Hash salted and/or iterated |
| 2600 | `md5(md5($pass))` | Raw Hash salted and/or iterated |
| 3910 | `md5(md5($pass).md5($salt))` | Raw Hash salted and/or iterated |
| 3500 | `md5(md5(md5($pass)))` | Raw Hash salted and/or iterated |
| 4400 | `md5(sha1($pass))` | Raw Hash salted and/or iterated |
| 4410 | `md5(sha1($pass).$salt)` | Raw Hash salted and/or iterated |
| 20900 | `md5(sha1($pass).md5($pass).sha1($pass))` | Raw Hash salted and/or iterated |
| 21200 | `md5(sha1($salt).md5($pass))` | Raw Hash salted and/or iterated |
| 4300 | `md5(strtoupper(md5($pass)))` | Raw Hash salted and/or iterated |
| 30 | `md5(utf16le($pass).$salt)` | Raw Hash salted and/or iterated |
| 110 | `sha1($pass.$salt)` | Raw Hash salted and/or iterated |
| 120 | `sha1($salt.$pass)` | Raw Hash salted and/or iterated |
| 4900 | `sha1($salt.$pass.$salt)` | Raw Hash salted and/or iterated |
| 4520 | `sha1($salt.sha1($pass))` | Raw Hash salted and/or iterated |
| 24300 | `sha1($salt.sha1($pass.$salt))` | Raw Hash salted and/or iterated |
| 140 | `sha1($salt.utf16le($pass))` | Raw Hash salted and/or iterated |
| 19300 | `sha1($salt1.$pass.$salt2)` | Raw Hash salted and/or iterated |
| 14400 | `sha1(CX)` | Raw Hash salted and/or iterated |
| 4700 | `sha1(md5($pass))` | Raw Hash salted and/or iterated |
| 4710 | `sha1(md5($pass).$salt)` | Raw Hash salted and/or iterated |
| 21100 | `sha1(md5($pass.$salt))` | Raw Hash salted and/or iterated |
| 18500 | `sha1(md5(md5($pass)))` | Raw Hash salted and/or iterated |
| 4500 | `sha1(sha1($pass))` | Raw Hash salted and/or iterated |
| 4510 | `sha1(sha1($pass).$salt)` | Raw Hash salted and/or iterated |
| 5000 | `sha1(sha1($salt.$pass.$salt))` | Raw Hash salted and/or iterated |
| 130 | `sha1(utf16le($pass).$salt)` | Raw Hash salted and/or iterated |
| 1410 | `sha256($pass.$salt)` | Raw Hash salted and/or iterated |
| 1420 | `sha256($salt.$pass)` | Raw Hash salted and/or iterated |
| 22300 | `sha256($salt.$pass.$salt)` | Raw Hash salted and/or iterated |
| 20720 | `sha256($salt.sha256($pass))` | Raw Hash salted and/or iterated |
| 21420 | `sha256($salt.sha256_bin($pass))` | Raw Hash salted and/or iterated |
| 1440 | `sha256($salt.utf16le($pass))` | Raw Hash salted and/or iterated |
| 20800 | `sha256(md5($pass))` | Raw Hash salted and/or iterated |
| 20710 | `sha256(sha256($pass).$salt)` | Raw Hash salted and/or iterated |
| 21400 | `sha256(sha256_bin($pass))` | Raw Hash salted and/or iterated |
| 1430 | `sha256(utf16le($pass).$salt)` | Raw Hash salted and/or iterated |
| 10810 | `sha384($pass.$salt)` | Raw Hash salted and/or iterated |
| 10820 | `sha384($salt.$pass)` | Raw Hash salted and/or iterated |
| 10840 | `sha384($salt.utf16le($pass))` | Raw Hash salted and/or iterated |
| 10830 | `sha384(utf16le($pass).$salt)` | Raw Hash salted and/or iterated |
| 1710 | `sha512($pass.$salt)` | Raw Hash salted and/or iterated |
| 1720 | `sha512($salt.$pass)` | Raw Hash salted and/or iterated |
| 1740 | `sha512($salt.utf16le($pass))` | Raw Hash salted and/or iterated |
| 1730 | `sha512(utf16le($pass).$salt)` | Raw Hash salted and/or iterated |
| 50 | `HMAC-MD5 (key = $pass)` | Raw Hash authenticated |
| 60 | `HMAC-MD5 (key = $salt)` | Raw Hash authenticated |
| 150 | `HMAC-SHA1 (key = $pass)` | Raw Hash authenticated |
| 160 | `HMAC-SHA1 (key = $salt)` | Raw Hash authenticated |
| 1450 | `HMAC-SHA256 (key = $pass)` | Raw Hash authenticated |
| 1460 | `HMAC-SHA256 (key = $salt)` | Raw Hash authenticated |
| 1750 | `HMAC-SHA512 (key = $pass)` | Raw Hash authenticated |
| 1760 | `HMAC-SHA512 (key = $salt)` | Raw Hash authenticated |
| 11750 | `HMAC-Streebog-256 (key = $pass), big-endian` | Raw Hash authenticated |
| 11760 | `HMAC-Streebog-256 (key = $salt), big-endian` | Raw Hash authenticated |
| 11850 | `HMAC-Streebog-512 (key = $pass), big-endian` | Raw Hash authenticated |
| 11860 | `HMAC-Streebog-512 (key = $salt), big-endian` | Raw Hash authenticated |
| 28700 | `Amazon AWS4-HMAC-SHA256` | Raw Hash authenticated |
| 11500 | `CRC32` | Raw Checksum |
| 27900 | `CRC32C` | Raw Checksum |
| 28000 | `CRC64Jones` | Raw Checksum |
| 18700 | `Java Object hashCode()` | Raw Checksum |
| 25700 | `MurmurHash` | Raw Checksum |
| 27800 | `MurmurHash3` | Raw Checksum |
| 14100 | `3DES (PT = $salt, key = $pass)` | Raw Cipher, Known-plaintext attack |
| 14000 | `DES (PT = $salt, key = $pass)` | Raw Cipher, Known-plaintext attack |
| 26401 | `AES-128-ECB NOKDF (PT = $salt, key = $pass)` | Raw Cipher, Known-plaintext attack |
| 26402 | `AES-192-ECB NOKDF (PT = $salt, key = $pass)` | Raw Cipher, Known-plaintext attack |
| 26403 | `AES-256-ECB NOKDF (PT = $salt, key = $pass)` | Raw Cipher, Known-plaintext attack |
| 15400 | `ChaCha20` | Raw Cipher, Known-plaintext attack |
| 14500 | `Linux Kernel Crypto API (2.4)` | Raw Cipher, Known-plaintext attack |
| 14900 | `Skip32 (PT = $salt, key = $pass)` | Raw Cipher, Known-plaintext attack |
| 11900 | `PBKDF2-HMAC-MD5` | Generic KDF |
| 12000 | `PBKDF2-HMAC-SHA1` | Generic KDF |
| 10900 | `PBKDF2-HMAC-SHA256` | Generic KDF |
| 12100 | `PBKDF2-HMAC-SHA512` | Generic KDF |
| 8900 | `scrypt` | Generic KDF |
| 400 | `phpass` | Generic KDF |
| 16100 | `TACACS+` | Network Protocol |
| 11400 | `SIP digest authentication (MD5)` | Network Protocol |
| 5300 | `IKE-PSK MD5` | Network Protocol |
| 5400 | `IKE-PSK SHA1` | Network Protocol |
| 25100 | `SNMPv3 HMAC-MD5-96` | Network Protocol |
| 25000 | `SNMPv3 HMAC-MD5-96/HMAC-SHA1-96` | Network Protocol |
| 25200 | `SNMPv3 HMAC-SHA1-96` | Network Protocol |
| 26700 | `SNMPv3 HMAC-SHA224-128` | Network Protocol |
| 26800 | `SNMPv3 HMAC-SHA256-192` | Network Protocol |
| 26900 | `SNMPv3 HMAC-SHA384-256` | Network Protocol |
| 27300 | `SNMPv3 HMAC-SHA512-384` | Network Protocol |
| 2500 | `WPA-EAPOL-PBKDF2` | Network Protocol |
| 2501 | `WPA-EAPOL-PMK` | Network Protocol |
| 22000 | `WPA-PBKDF2-PMKID+EAPOL` | Network Protocol |
| 22001 | `WPA-PMK-PMKID+EAPOL` | Network Protocol |
| 16800 | `WPA-PMKID-PBKDF2` | Network Protocol |
| 16801 | `WPA-PMKID-PMK` | Network Protocol |
| 7300 | `IPMI2 RAKP HMAC-SHA1` | Network Protocol |
| 10200 | `CRAM-MD5` | Network Protocol |
| 16500 | `JWT (JSON Web Token)` | Network Protocol |
| 29200 | `Radmin3` | Network Protocol |
| 19600 | `Kerberos 5, etype 17, TGS-REP` | Network Protocol |
| 19800 | `Kerberos 5, etype 17, Pre-Auth` | Network Protocol |
| 28800 | `Kerberos 5, etype 17, DB` | Network Protocol |
| 19700 | `Kerberos 5, etype 18, TGS-REP` | Network Protocol |
| 19900 | `Kerberos 5, etype 18, Pre-Auth` | Network Protocol |
| 28900 | `Kerberos 5, etype 18, DB` | Network Protocol |
| 7500 | `Kerberos 5, etype 23, AS-REQ Pre-Auth` | Network Protocol |
| 13100 | `Kerberos 5, etype 23, TGS-REP` | Network Protocol |
| 18200 | `Kerberos 5, etype 23, AS-REP` | Network Protocol |
| 5500 | `NetNTLMv1 / NetNTLMv1+ESS` | Network Protocol |
| 27000 | `NetNTLMv1 / NetNTLMv1+ESS (NT)` | Network Protocol |
| 5600 | `NetNTLMv2` | Network Protocol |
| 27100 | `NetNTLMv2 (NT)` | Network Protocol |
| 29100 | `Flask Session Cookie ($salt.$salt.$pass)` | Network Protocol |
| 4800 | `iSCSI CHAP authentication, MD5(CHAP)` | Network Protocol |
| 8500 | `RACF` | Operating System |
| 6300 | `AIX {smd5}` | Operating System |
| 6700 | `AIX {ssha1}` | Operating System |
| 6400 | `AIX {ssha256}` | Operating System |
| 6500 | `AIX {ssha512}` | Operating System |
| 3000 | `LM` | Operating System |
| 19000 | `QNX /etc/shadow (MD5)` | Operating System |
| 19100 | `QNX /etc/shadow (SHA256)` | Operating System |
| 19200 | `QNX /etc/shadow (SHA512)` | Operating System |
| 15300 | `DPAPI masterkey file v1 (context 1 and 2)` | Operating System |
| 15310 | `DPAPI masterkey file v1 (context 3)` | Operating System |
| 15900 | `DPAPI masterkey file v2 (context 1 and 2)` | Operating System |
| 15910 | `DPAPI masterkey file v2 (context 3)` | Operating System |
| 7200 | `GRUB 2` | Operating System |
| 12800 | `MS-AzureSync PBKDF2-HMAC-SHA256` | Operating System |
| 12400 | `BSDi Crypt, Extended DES` | Operating System |
| 1000 | `NTLM` | Operating System |
| 9900 | `Radmin2` | Operating System |
| 5800 | `Samsung Android Password/PIN` | Operating System |
| 28100 | `Windows Hello PIN/Password` | Operating System |
| 13800 | `Windows Phone 8+ PIN/password` | Operating System |
| 2410 | `Cisco-ASA MD5` | Operating System |
| 9200 | `Cisco-IOS $8$ (PBKDF2-SHA256)` | Operating System |
| 9300 | `Cisco-IOS $9$ (scrypt)` | Operating System |
| 5700 | `Cisco-IOS type 4 (SHA256)` | Operating System |
| 2400 | `Cisco-PIX MD5` | Operating System |
| 8100 | `Citrix NetScaler (SHA1)` | Operating System |
| 22200 | `Citrix NetScaler (SHA512)` | Operating System |
| 1100 | `Domain Cached Credentials (DCC), MS Cache` | Operating System |
| 2100 | `Domain Cached Credentials 2 (DCC2), MS Cache 2` | Operating System |
| 7000 | `FortiGate (FortiOS)` | Operating System |
| 26300 | `FortiGate256 (FortiOS256)` | Operating System |
| 125 | `ArubaOS` | Operating System |
| 501 | `Juniper IVE` | Operating System |
| 22 | `Juniper NetScreen/SSG (ScreenOS)` | Operating System |
| 15100 | `Juniper/NetBSD sha1crypt` | Operating System |
| 26500 | `iPhone passcode (UID key + System Keybag)` | Operating System |
| 122 | `macOS v10.4, macOS v10.5, macOS v10.6` | Operating System |
| 1722 | `macOS v10.7` | Operating System |
| 7100 | `macOS v10.8+ (PBKDF2-SHA512)` | Operating System |
| 3200 | `bcrypt $2*$, Blowfish (Unix)` | Operating System |
| 500 | `md5crypt, MD5 (Unix), Cisco-IOS $1$ (MD5)` | Operating System |
| 1500 | `descrypt, DES (Unix), Traditional DES` | Operating System |
| 29000 | `sha1($salt.sha1(utf16le($username).':'.utf16le($pass)))` | Operating System |
| 7400 | `sha256crypt $5$, SHA256 (Unix)` | Operating System |
| 1800 | `sha512crypt $6$, SHA512 (Unix)` | Operating System |
| 24600 | `SQLCipher` | Database Server |
| 131 | `MSSQL (2000)` | Database Server |
| 132 | `MSSQL (2005)` | Database Server |
| 1731 | `MSSQL (2012, 2014)` | Database Server |
| 24100 | `MongoDB ServerKey SCRAM-SHA-1` | Database Server |
| 24200 | `MongoDB ServerKey SCRAM-SHA-256` | Database Server |
| 12 | `PostgreSQL` | Database Server |
| 11100 | `PostgreSQL CRAM (MD5)` | Database Server |
| 28600 | `PostgreSQL SCRAM-SHA-256` | Database Server |
| 3100 | `Oracle H: Type (Oracle 7+)` | Database Server |
| 112 | `Oracle S: Type (Oracle 11+)` | Database Server |
| 12300 | `Oracle T: Type (Oracle 12+)` | Database Server |
| 7401 | `MySQL $A$ (sha256crypt)` | Database Server |
| 11200 | `MySQL CRAM (SHA1)` | Database Server |
| 200 | `MySQL323` | Database Server |
| 300 | `MySQL4.1/MySQL5` | Database Server |
| 8000 | `Sybase ASE` | Database Server |
| 8300 | `DNSSEC (NSEC3)` | FTP, HTTP, SMTP, LDAP Server |
| 25900 | `KNX IP Secure - Device Authentication Code` | FTP, HTTP, SMTP, LDAP Server |
| 16400 | `CRAM-MD5 Dovecot` | FTP, HTTP, SMTP, LDAP Server |
| 1411 | `SSHA-256(Base64), LDAP {SSHA256}` | FTP, HTTP, SMTP, LDAP Server |
| 1711 | `SSHA-512(Base64), LDAP {SSHA512}` | FTP, HTTP, SMTP, LDAP Server |
| 24900 | `Dahua Authentication MD5` | FTP, HTTP, SMTP, LDAP Server |
| 10901 | `RedHat 389-DS LDAP (PBKDF2-HMAC-SHA256)` | FTP, HTTP, SMTP, LDAP Server |
| 15000 | `FileZilla Server >= 0.9.55` | FTP, HTTP, SMTP, LDAP Server |
| 12600 | `ColdFusion 10+` | FTP, HTTP, SMTP, LDAP Server |
| 1600 | `Apache $apr1$ MD5, md5apr1, MD5 (APR)` | FTP, HTTP, SMTP, LDAP Server |
| 141 | `Episerver 6.x < .NET 4` | FTP, HTTP, SMTP, LDAP Server |
| 1441 | `Episerver 6.x >= .NET 4` | FTP, HTTP, SMTP, LDAP Server |
| 1421 | `hMailServer` | FTP, HTTP, SMTP, LDAP Server |
| 101 | `nsldap, SHA-1(Base64), Netscape LDAP SHA` | FTP, HTTP, SMTP, LDAP Server |
| 111 | `nsldaps, SSHA-1(Base64), Netscape LDAP SSHA` | FTP, HTTP, SMTP, LDAP Server |
| 7700 | `SAP CODVN B (BCODE)` | Enterprise Application Software (EAS) |
| 7701 | `SAP CODVN B (BCODE) from RFC_READ_TABLE` | Enterprise Application Software (EAS) |
| 7800 | `SAP CODVN F/G (PASSCODE)` | Enterprise Application Software (EAS) |
| 7801 | `SAP CODVN F/G (PASSCODE) from RFC_READ_TABLE` | Enterprise Application Software (EAS) |
| 10300 | `SAP CODVN H (PWDSALTEDHASH) iSSHA-1` | Enterprise Application Software (EAS) |
| 133 | `PeopleSoft` | Enterprise Application Software (EAS) |
| 13500 | `PeopleSoft PS_TOKEN` | Enterprise Application Software (EAS) |
| 21500 | `SolarWinds Orion` | Enterprise Application Software (EAS) |
| 21501 | `SolarWinds Orion v2` | Enterprise Application Software (EAS) |
| 24 | `SolarWinds Serv-U` | Enterprise Application Software (EAS) |
| 8600 | `Lotus Notes/Domino 5` | Enterprise Application Software (EAS) |
| 8700 | `Lotus Notes/Domino 6` | Enterprise Application Software (EAS) |
| 9100 | `Lotus Notes/Domino 8` | Enterprise Application Software (EAS) |
| 26200 | `OpenEdge Progress Encode` | Enterprise Application Software (EAS) |
| 20600 | `Oracle Transportation Management (SHA256)` | Enterprise Application Software (EAS) |
| 4711 | `Huawei sha1(md5($pass).$salt)` | Enterprise Application Software (EAS) |
| 20711 | `AuthMe sha256` | Enterprise Application Software (EAS) |
| 22400 | `AES Crypt (SHA256)` | Full-Disk Encryption (FDE) |
| 27400 | `VMware VMX (PBKDF2-HMAC-SHA1 + AES-256-CBC)` | Full-Disk Encryption (FDE) |
| 14600 | `LUKS v1 (legacy)` | Full-Disk Encryption (FDE) |
| 29541 | `LUKS v1 RIPEMD-160 + AES` | Full-Disk Encryption (FDE) |
| 29542 | `LUKS v1 RIPEMD-160 + Serpent` | Full-Disk Encryption (FDE) |
| 29543 | `LUKS v1 RIPEMD-160 + Twofish` | Full-Disk Encryption (FDE) |
| 29511 | `LUKS v1 SHA-1 + AES` | Full-Disk Encryption (FDE) |
| 29512 | `LUKS v1 SHA-1 + Serpent` | Full-Disk Encryption (FDE) |
| 29513 | `LUKS v1 SHA-1 + Twofish` | Full-Disk Encryption (FDE) |
| 29521 | `LUKS v1 SHA-256 + AES` | Full-Disk Encryption (FDE) |
| 29522 | `LUKS v1 SHA-256 + Serpent` | Full-Disk Encryption (FDE) |
| 29523 | `LUKS v1 SHA-256 + Twofish` | Full-Disk Encryption (FDE) |
| 29531 | `LUKS v1 SHA-512 + AES` | Full-Disk Encryption (FDE) |
| 29532 | `LUKS v1 SHA-512 + Serpent` | Full-Disk Encryption (FDE) |
| 29533 | `LUKS v1 SHA-512 + Twofish` | Full-Disk Encryption (FDE) |
| 13711 | `VeraCrypt RIPEMD160 + XTS 512 bit (legacy)` | Full-Disk Encryption (FDE) |
| 13712 | `VeraCrypt RIPEMD160 + XTS 1024 bit (legacy)` | Full-Disk Encryption (FDE) |
| 13713 | `VeraCrypt RIPEMD160 + XTS 1536 bit (legacy)` | Full-Disk Encryption (FDE) |
| 13741 | `VeraCrypt RIPEMD160 + XTS 512 bit + boot-mode (legacy)` | Full-Disk Encryption (FDE) |
| 13742 | `VeraCrypt RIPEMD160 + XTS 1024 bit + boot-mode (legacy)` | Full-Disk Encryption (FDE) |
| 13743 | `VeraCrypt RIPEMD160 + XTS 1536 bit + boot-mode (legacy)` | Full-Disk Encryption (FDE) |
| 29411 | `VeraCrypt RIPEMD160 + XTS 512 bit` | Full-Disk Encryption (FDE) |
| 29412 | `VeraCrypt RIPEMD160 + XTS 1024 bit` | Full-Disk Encryption (FDE) |
| 29413 | `VeraCrypt RIPEMD160 + XTS 1536 bit` | Full-Disk Encryption (FDE) |
| 29441 | `VeraCrypt RIPEMD160 + XTS 512 bit + boot-mode` | Full-Disk Encryption (FDE) |
| 29442 | `VeraCrypt RIPEMD160 + XTS 1024 bit + boot-mode` | Full-Disk Encryption (FDE) |
| 29443 | `VeraCrypt RIPEMD160 + XTS 1536 bit + boot-mode` | Full-Disk Encryption (FDE) |
| 13751 | `VeraCrypt SHA256 + XTS 512 bit (legacy)` | Full-Disk Encryption (FDE) |
| 13752 | `VeraCrypt SHA256 + XTS 1024 bit (legacy)` | Full-Disk Encryption (FDE) |
| 13753 | `VeraCrypt SHA256 + XTS 1536 bit (legacy)` | Full-Disk Encryption (FDE) |
| 13761 | `VeraCrypt SHA256 + XTS 512 bit + boot-mode (legacy)` | Full-Disk Encryption (FDE) |
| 13762 | `VeraCrypt SHA256 + XTS 1024 bit + boot-mode (legacy)` | Full-Disk Encryption (FDE) |
| 13763 | `VeraCrypt SHA256 + XTS 1536 bit + boot-mode (legacy)` | Full-Disk Encryption (FDE) |
| 29451 | `VeraCrypt SHA256 + XTS 512 bit` | Full-Disk Encryption (FDE) |
| 29452 | `VeraCrypt SHA256 + XTS 1024 bit` | Full-Disk Encryption (FDE) |
| 29453 | `VeraCrypt SHA256 + XTS 1536 bit` | Full-Disk Encryption (FDE) |
| 29461 | `VeraCrypt SHA256 + XTS 512 bit + boot-mode` | Full-Disk Encryption (FDE) |
| 29462 | `VeraCrypt SHA256 + XTS 1024 bit + boot-mode` | Full-Disk Encryption (FDE) |
| 29463 | `VeraCrypt SHA256 + XTS 1536 bit + boot-mode` | Full-Disk Encryption (FDE) |
| 13721 | `VeraCrypt SHA512 + XTS 512 bit (legacy)` | Full-Disk Encryption (FDE) |
| 13722 | `VeraCrypt SHA512 + XTS 1024 bit (legacy)` | Full-Disk Encryption (FDE) |
| 13723 | `VeraCrypt SHA512 + XTS 1536 bit (legacy)` | Full-Disk Encryption (FDE) |
| 29421 | `VeraCrypt SHA512 + XTS 512 bit` | Full-Disk Encryption (FDE) |
| 29422 | `VeraCrypt SHA512 + XTS 1024 bit` | Full-Disk Encryption (FDE) |
| 29423 | `VeraCrypt SHA512 + XTS 1536 bit` | Full-Disk Encryption (FDE) |
| 13771 | `VeraCrypt Streebog-512 + XTS 512 bit (legacy)` | Full-Disk Encryption (FDE) |
| 13772 | `VeraCrypt Streebog-512 + XTS 1024 bit (legacy)` | Full-Disk Encryption (FDE) |
| 13773 | `VeraCrypt Streebog-512 + XTS 1536 bit (legacy)` | Full-Disk Encryption (FDE) |
| 13781 | `VeraCrypt Streebog-512 + XTS 512 bit + boot-mode (legacy)` | Full-Disk Encryption (FDE) |
| 13782 | `VeraCrypt Streebog-512 + XTS 1024 bit + boot-mode (legacy)` | Full-Disk Encryption (FDE) |
| 13783 | `VeraCrypt Streebog-512 + XTS 1536 bit + boot-mode (legacy)` | Full-Disk Encryption (FDE) |
| 29471 | `VeraCrypt Streebog-512 + XTS 512 bit` | Full-Disk Encryption (FDE) |
| 29472 | `VeraCrypt Streebog-512 + XTS 1024 bit` | Full-Disk Encryption (FDE) |
| 29473 | `VeraCrypt Streebog-512 + XTS 1536 bit` | Full-Disk Encryption (FDE) |
| 29481 | `VeraCrypt Streebog-512 + XTS 512 bit + boot-mode` | Full-Disk Encryption (FDE) |
| 29482 | `VeraCrypt Streebog-512 + XTS 1024 bit + boot-mode` | Full-Disk Encryption (FDE) |
| 29483 | `VeraCrypt Streebog-512 + XTS 1536 bit + boot-mode` | Full-Disk Encryption (FDE) |
| 13731 | `VeraCrypt Whirlpool + XTS 512 bit (legacy)` | Full-Disk Encryption (FDE) |
| 13732 | `VeraCrypt Whirlpool + XTS 1024 bit (legacy)` | Full-Disk Encryption (FDE) |
| 13733 | `VeraCrypt Whirlpool + XTS 1536 bit (legacy)` | Full-Disk Encryption (FDE) |
| 29431 | `VeraCrypt Whirlpool + XTS 512 bit` | Full-Disk Encryption (FDE) |
| 29432 | `VeraCrypt Whirlpool + XTS 1024 bit` | Full-Disk Encryption (FDE) |
| 29433 | `VeraCrypt Whirlpool + XTS 1536 bit` | Full-Disk Encryption (FDE) |
| 23900 | `BestCrypt v3 Volume Encryption` | Full-Disk Encryption (FDE) |
| 16700 | `FileVault 2` | Full-Disk Encryption (FDE) |
| 27500 | `VirtualBox (PBKDF2-HMAC-SHA256 & AES-128-XTS)` | Full-Disk Encryption (FDE) |
| 27600 | `VirtualBox (PBKDF2-HMAC-SHA256 & AES-256-XTS)` | Full-Disk Encryption (FDE) |
| 20011 | `DiskCryptor SHA512 + XTS 512 bit` | Full-Disk Encryption (FDE) |
| 20012 | `DiskCryptor SHA512 + XTS 1024 bit` | Full-Disk Encryption (FDE) |
| 20013 | `DiskCryptor SHA512 + XTS 1536 bit` | Full-Disk Encryption (FDE) |
| 22100 | `BitLocker` | Full-Disk Encryption (FDE) |
| 12900 | `Android FDE (Samsung DEK)` | Full-Disk Encryption (FDE) |
| 8800 | `Android FDE <= 4.3` | Full-Disk Encryption (FDE) |
| 18300 | `Apple File System (APFS)` | Full-Disk Encryption (FDE) |
| 6211 | `TrueCrypt RIPEMD160 + XTS 512 bit (legacy)` | Full-Disk Encryption (FDE) |
| 6212 | `TrueCrypt RIPEMD160 + XTS 1024 bit (legacy)` | Full-Disk Encryption (FDE) |
| 6213 | `TrueCrypt RIPEMD160 + XTS 1536 bit (legacy)` | Full-Disk Encryption (FDE) |
| 6241 | `TrueCrypt RIPEMD160 + XTS 512 bit + boot-mode (legacy)` | Full-Disk Encryption (FDE) |
| 6242 | `TrueCrypt RIPEMD160 + XTS 1024 bit + boot-mode (legacy)` | Full-Disk Encryption (FDE) |
| 6243 | `TrueCrypt RIPEMD160 + XTS 1536 bit + boot-mode (legacy)` | Full-Disk Encryption (FDE) |
| 29311 | `TrueCrypt RIPEMD160 + XTS 512 bit` | Full-Disk Encryption (FDE) |
| 29312 | `TrueCrypt RIPEMD160 + XTS 1024 bit` | Full-Disk Encryption (FDE) |
| 29313 | `TrueCrypt RIPEMD160 + XTS 1536 bit` | Full-Disk Encryption (FDE) |
| 29341 | `TrueCrypt RIPEMD160 + XTS 512 bit + boot-mode` | Full-Disk Encryption (FDE) |
| 29342 | `TrueCrypt RIPEMD160 + XTS 1024 bit + boot-mode` | Full-Disk Encryption (FDE) |
| 29343 | `TrueCrypt RIPEMD160 + XTS 1536 bit + boot-mode` | Full-Disk Encryption (FDE) |
| 6221 | `TrueCrypt SHA512 + XTS 512 bit (legacy)` | Full-Disk Encryption (FDE) |
| 6222 | `TrueCrypt SHA512 + XTS 1024 bit (legacy)` | Full-Disk Encryption (FDE) |
| 6223 | `TrueCrypt SHA512 + XTS 1536 bit (legacy)` | Full-Disk Encryption (FDE) |
| 29321 | `TrueCrypt SHA512 + XTS 512 bit` | Full-Disk Encryption (FDE) |
| 29322 | `TrueCrypt SHA512 + XTS 1024 bit` | Full-Disk Encryption (FDE) |
| 29323 | `TrueCrypt SHA512 + XTS 1536 bit` | Full-Disk Encryption (FDE) |
| 6231 | `TrueCrypt Whirlpool + XTS 512 bit (legacy)` | Full-Disk Encryption (FDE) |
| 6232 | `TrueCrypt Whirlpool + XTS 1024 bit (legacy)` | Full-Disk Encryption (FDE) |
| 6233 | `TrueCrypt Whirlpool + XTS 1536 bit (legacy)` | Full-Disk Encryption (FDE) |
| 29331 | `TrueCrypt Whirlpool + XTS 512 bit` | Full-Disk Encryption (FDE) |
| 29332 | `TrueCrypt Whirlpool + XTS 1024 bit` | Full-Disk Encryption (FDE) |
| 29333 | `TrueCrypt Whirlpool + XTS 1536 bit` | Full-Disk Encryption (FDE) |
| 12200 | `eCryptfs` | Full-Disk Encryption (FDE) |
| 10400 | `PDF 1.1 - 1.3 (Acrobat 2 - 4)` | Document |
| 10410 | `PDF 1.1 - 1.3 (Acrobat 2 - 4), collider #1` | Document |
| 10420 | `PDF 1.1 - 1.3 (Acrobat 2 - 4), collider #2` | Document |
| 10500 | `PDF 1.4 - 1.6 (Acrobat 5 - 8)` | Document |
| 25400 | `PDF 1.4 - 1.6 (Acrobat 5 - 8) - user and owner pass` | Document |
| 10600 | `PDF 1.7 Level 3 (Acrobat 9)` | Document |
| 10700 | `PDF 1.7 Level 8 (Acrobat 10 - 11)` | Document |
| 9400 | `MS Office 2007` | Document |
| 9500 | `MS Office 2010` | Document |
| 9600 | `MS Office 2013` | Document |
| 25300 | `MS Office 2016 - SheetProtection` | Document |
| 9700 | `MS Office <= 2003 $0/$1, MD5 + RC4` | Document |
| 9710 | `MS Office <= 2003 $0/$1, MD5 + RC4, collider #1` | Document |
| 9720 | `MS Office <= 2003 $0/$1, MD5 + RC4, collider #2` | Document |
| 9810 | `MS Office <= 2003 $3, SHA1 + RC4, collider #1` | Document |
| 9820 | `MS Office <= 2003 $3, SHA1 + RC4, collider #2` | Document |
| 9800 | `MS Office <= 2003 $3/$4, SHA1 + RC4` | Document |
| 18400 | `Open Document Format (ODF) 1.2 (SHA-256, AES)` | Document |
| 18600 | `Open Document Format (ODF) 1.1 (SHA-1, Blowfish)` | Document |
| 16200 | `Apple Secure Notes` | Document |
| 23300 | `Apple iWork` | Document |
| 6600 | `1Password, agilekeychain` | Password Manager |
| 8200 | `1Password, cloudkeychain` | Password Manager |
| 9000 | `Password Safe v2` | Password Manager |
| 5200 | `Password Safe v3` | Password Manager |
| 6800 | `LastPass + LastPass sniffed` | Password Manager |
| 13400 | `KeePass 1 (AES/Twofish) and KeePass 2 (AES)` | Password Manager |
| 29700 | `KeePass 1 (AES/Twofish) and KeePass 2 (AES) - keyfile only mode` | Password Manager |
| 23400 | `Bitwarden` | Password Manager |
| 16900 | `Ansible Vault` | Password Manager |
| 26000 | `Mozilla key3.db` | Password Manager |
| 26100 | `Mozilla key4.db` | Password Manager |
| 23100 | `Apple Keychain` | Password Manager |
| 11600 | `7-Zip` | Archive |
| 12500 | `RAR3-hp` | Archive |
| 23800 | `RAR3-p (Compressed)` | Archive |
| 23700 | `RAR3-p (Uncompressed)` | Archive |
| 13000 | `RAR5` | Archive |
| 17220 | `PKZIP (Compressed Multi-File)` | Archive |
| 17200 | `PKZIP (Compressed)` | Archive |
| 17225 | `PKZIP (Mixed Multi-File)` | Archive |
| 17230 | `PKZIP (Mixed Multi-File Checksum-Only)` | Archive |
| 17210 | `PKZIP (Uncompressed)` | Archive |
| 20500 | `PKZIP Master Key` | Archive |
| 20510 | `PKZIP Master Key (6 byte optimization)` | Archive |
| 23001 | `SecureZIP AES-128` | Archive |
| 23002 | `SecureZIP AES-192` | Archive |
| 23003 | `SecureZIP AES-256` | Archive |
| 13600 | `WinZip` | Archive |
| 18900 | `Android Backup` | Archive |
| 24700 | `Stuffit5` | Archive |
| 13200 | `AxCrypt 1` | Archive |
| 13300 | `AxCrypt 1 in-memory SHA1` | Archive |
| 23500 | `AxCrypt 2 AES-128` | Archive |
| 23600 | `AxCrypt 2 AES-256` | Archive |
| 14700 | `iTunes backup < 10.0` | Archive |
| 14800 | `iTunes backup >= 10.0` | Archive |
| 8400 | `WBB3 (Woltlab Burning Board)` | Forums, CMS, E-Commerce |
| 2612 | `PHPS` | Forums, CMS, E-Commerce |
| 121 | `SMF (Simple Machines Forum) > v1.1` | Forums, CMS, E-Commerce |
| 3711 | `MediaWiki B type` | Forums, CMS, E-Commerce |
| 4521 | `Redmine` | Forums, CMS, E-Commerce |
| 24800 | `Umbraco HMAC-SHA1` | Forums, CMS, E-Commerce |
| 11 | `Joomla < 2.5.18` | Forums, CMS, E-Commerce |
| 13900 | `OpenCart` | Forums, CMS, E-Commerce |
| 11000 | `PrestaShop` | Forums, CMS, E-Commerce |
| 16000 | `Tripcode` | Forums, CMS, E-Commerce |
| 7900 | `Drupal7` | Forums, CMS, E-Commerce |
| 4522 | `PunBB` | Forums, CMS, E-Commerce |
| 2811 | `MyBB 1.2+, IPB2+ (Invision Power Board)` | Forums, CMS, E-Commerce |
| 2611 | `vBulletin < v3.8.5` | Forums, CMS, E-Commerce |
| 2711 | `vBulletin >= v3.8.5` | Forums, CMS, E-Commerce |
| 25600 | `bcrypt(md5($pass)) / bcryptmd5` | Forums, CMS, E-Commerce |
| 25800 | `bcrypt(sha1($pass)) / bcryptsha1` | Forums, CMS, E-Commerce |
| 28400 | `bcrypt(sha512($pass)) / bcryptsha512` | Forums, CMS, E-Commerce |
| 21 | `osCommerce, xt:Commerce` | Forums, CMS, E-Commerce |
| 18100 | `TOTP (HMAC-SHA1)` | One-Time Password |
| 2000 | `STDOUT` | Plaintext |
| 99999 | `Plaintext` | Plaintext |
| 21600 | `Web2py pbkdf2-sha512` | Framework |
| 10000 | `Django (PBKDF2-SHA256)` | Framework |
| 124 | `Django (SHA-1)` | Framework |
| 12001 | `Atlassian (PBKDF2-HMAC-SHA1)` | Framework |
| 19500 | `Ruby on Rails Restful-Authentication` | Framework |
| 27200 | `Ruby on Rails Restful Auth (one round, no sitekey)` | Framework |
| 30000 | `Python Werkzeug MD5 (HMAC-MD5 (key = $salt))` | Framework |
| 30120 | `Python Werkzeug SHA256 (HMAC-SHA256 (key = $salt))` | Framework |
| 20200 | `Python passlib pbkdf2-sha512` | Framework |
| 20300 | `Python passlib pbkdf2-sha256` | Framework |
| 20400 | `Python passlib pbkdf2-sha1` | Framework |
| 24410 | `PKCS#8 Private Keys (PBKDF2-HMAC-SHA1 + 3DES/AES)` | Private Key |
| 24420 | `PKCS#8 Private Keys (PBKDF2-HMAC-SHA256 + 3DES/AES)` | Private Key |
| 15500 | `JKS Java Key Store Private Keys (SHA1)` | Private Key |
| 22911 | `RSA/DSA/EC/OpenSSH Private Keys ($0$)` | Private Key |
| 22921 | `RSA/DSA/EC/OpenSSH Private Keys ($6$)` | Private Key |
| 22931 | `RSA/DSA/EC/OpenSSH Private Keys ($1, $3$)` | Private Key |
| 22941 | `RSA/DSA/EC/OpenSSH Private Keys ($4$)` | Private Key |
| 22951 | `RSA/DSA/EC/OpenSSH Private Keys ($5$)` | Private Key |
| 23200 | `XMPP SCRAM PBKDF2-SHA1` | Instant Messaging Service |
| 28300 | `Teamspeak 3 (channel hash)` | Instant Messaging Service |
| 22600 | `Telegram Desktop < v2.1.14 (PBKDF2-HMAC-SHA1)` | Instant Messaging Service |
| 24500 | `Telegram Desktop >= v2.1.14 (PBKDF2-HMAC-SHA512)` | Instant Messaging Service |
| 22301 | `Telegram Mobile App Passcode (SHA256)` | Instant Messaging Service |
| 23 | `Skype` | Instant Messaging Service |
| 29600 | `Terra Station Wallet (AES256-CBC(PBKDF2($pass)))` | Cryptocurrency Wallet |
| 26600 | `MetaMask Wallet` | Cryptocurrency Wallet |
| 21000 | `BitShares v0.x - sha512(sha512_bin(pass))` | Cryptocurrency Wallet |
| 28501 | `Bitcoin WIF private key (P2PKH), compressed` | Cryptocurrency Wallet |
| 28502 | `Bitcoin WIF private key (P2PKH), uncompressed` | Cryptocurrency Wallet |
| 28503 | `Bitcoin WIF private key (P2WPKH, Bech32), compressed` | Cryptocurrency Wallet |
| 28504 | `Bitcoin WIF private key (P2WPKH, Bech32), uncompressed` | Cryptocurrency Wallet |
| 28505 | `Bitcoin WIF private key (P2SH(P2WPKH)), compressed` | Cryptocurrency Wallet |
| 28506 | `Bitcoin WIF private key (P2SH(P2WPKH)), uncompressed` | Cryptocurrency Wallet |
| 11300 | `Bitcoin/Litecoin wallet.dat` | Cryptocurrency Wallet |
| 16600 | `Electrum Wallet (Salt-Type 1-3)` | Cryptocurrency Wallet |
| 21700 | `Electrum Wallet (Salt-Type 4)` | Cryptocurrency Wallet |
| 21800 | `Electrum Wallet (Salt-Type 5)` | Cryptocurrency Wallet |
| 12700 | `Blockchain, My Wallet` | Cryptocurrency Wallet |
| 15200 | `Blockchain, My Wallet, V2` | Cryptocurrency Wallet |
| 18800 | `Blockchain, My Wallet, Second Password (SHA256)` | Cryptocurrency Wallet |
| 25500 | `Stargazer Stellar Wallet XLM` | Cryptocurrency Wallet |
| 16300 | `Ethereum Pre-Sale Wallet, PBKDF2-HMAC-SHA256` | Cryptocurrency Wallet |
| 15600 | `Ethereum Wallet, PBKDF2-HMAC-SHA256` | Cryptocurrency Wallet |
| 15700 | `Ethereum Wallet, SCRYPT` | Cryptocurrency Wallet |
| 22500 | `MultiBit Classic .key (MD5)` | Cryptocurrency Wallet |
| 27700 | `MultiBit Classic .wallet (scrypt)` | Cryptocurrency Wallet |
| 22700 | `MultiBit HD (scrypt)` | Cryptocurrency Wallet |
| 28200 | `Exodus Desktop Wallet (scrypt)` | Cryptocurrency Wallet |
## Дополнительные ресурсы
- [Официальная документация Hashcat](https://hashcat.net/wiki/doku.php?id=hashcat)
- [Руководство пользователя Hashcat](https://hashcat.net/hashcat/)