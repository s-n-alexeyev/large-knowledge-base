ffbp - утилита которая показывает прогресс бар, можно использовать при запуске вместо ffmpeg
https://github.com/althonos/ffpb

>Вырезаем рекламу из скаченного ролика
```bash
#!/bin/bash

if [ $# -eq 0 ]; then
  # Если нет аргументов, используйте YAD для ввода значений
  input_file=$(yad --file --title="Выберите видеофайл" --width=600 --height=400)
  start_time=$(yad --entry --title="Введите время начала" --text="Формат: HH:MM:SS" --width=300)
  end_time=$(yad --entry --title="Введите время окончания" --text="Формат: HH:MM:SS" --width=300)
else
  input_file="$1"
  start_time="$2"
  end_time="$3"
fi

if [ ! -f "$input_file" ]; then
  echo "Ошибка: Входной файл не существует."
  exit 1
fi

if ! ffmpeg -i "$input_file" -t 1 -ss "$start_time" -to "$end_time" -c copy -f null /dev/null 2>&1; then
  echo "Ошибка: Некорректные временные метки. Убедитесь, что они в формате HH:MM:SS или SS."
  exit 1
fi

# Получите директорию и имя файла без расширения из входного файла
input_dir="$(dirname "$input_file")"
input_filename="$(basename "$input_file" | cut -f 1 -d '.')"

# Создайте временные файлы для фрагмента и оставшейся части
tmp_fragment1_file="$input_dir/fragment1.mp4"
tmp_fragment2_file="$input_dir/fragment2.mp4"

# Функция для преобразования времени в формат HH:MM:SS
format_time() {
  local input_time="$1"
  if [[ "$input_time" =~ ^[0-9]$ ]]; then
    # Если только одна цифра, добавьте 00:00:
    echo "00:00:0$input_time"
  elif [[ "$input_time" =~ ^[0-9]{2}$ ]]; then
    # Если две цифры, добавьте 00:
    echo "00:00:$input_time"
  else
    # В противном случае верните время без изменений
    echo "$input_time"
  fi
}

# Преобразуйте время начала и конца
start_time_formatted=$(format_time "$start_time")
end_time_formatted=$(format_time "$end_time")

if [ "$start_time_formatted" != "00:00:00" ]; then
  # Вырежьте фрагмент из начала видео
  ffmpeg -i "$input_file" -ss 00:00:00 -to "$start_time_formatted" -c copy "$tmp_fragment1_file" -loglevel error

  # Вырежьте оставшуюся часть видео
  ffmpeg -i "$input_file" -ss "$end_time_formatted" -c copy "$tmp_fragment2_file" -loglevel error

  # Создайте текстовый файл с именами временных файлов
  concat_list="$input_dir/concat_list.txt"
  echo "file '$tmp_fragment1_file'" > "$concat_list"
  echo "file '$tmp_fragment2_file'" >> "$concat_list"

  # Объедините фрагмент и оставшуюся часть
  ffmpeg -f concat -safe 0 -i "$concat_list" -c copy "$input_dir/${input_filename}_cut.mp4" -loglevel error

  # Удалите временные файлы и список
  rm "$tmp_fragment1_file" "$tmp_fragment2_file" "$concat_list"
else
  # Если время начала равно 00:00:00, используйте только второй фрагмент
  ffmpeg -i "$input_file" -ss "$end_time_formatted" -c copy "$input_dir/${input_filename}_cut.mp4" -loglevel error
fi

echo "Готово! Файл с именем ${input_filename}_cut.mp4 был создан в директории $input_dir"

```

>Скрипт объединяет внешнюю дорожу в формате `mp3`, микширует звук с внутренней дорожкой (10% к 90%), добавляет в качестве первой звуковой дорожки нашу созданную, оставляя при этом существующую в качестве второй звуковой дорожки, формат аудио `aac`.
>Также добавляются субтитры.
>Все происходит автоматически со всеми файлами в директории.
>Имена файлов берутся по имени видеофайла с расширением `mp4`.
```bash
#!/bin/bash

output_directory="Done"

# Создание папки "Done," если её нет
mkdir -p "$output_directory"

for input_video in *.mp4; do
  input_filename="${input_video%.*}"  # Получаем имя файла без расширения
  input_audio="${input_filename}.mp3"
  input_subtitles="${input_filename}.srt"
  output_file="$output_directory/${input_filename}.mp4"

  # Проверка, существует ли итоговый файл, если да, пропускаем кодирование
  if [ -f "$output_file" ]; then
    echo "Файл $output_file уже существует. Пропускаем кодирование."
    continue
  fi

  echo "Шаг 1: Извлечение аудиодорожки из видеофайла"
  ffmpeg -i "$input_video" -vn -acodec copy extracted_audio.aac

  echo "Шаг 2: Вычисление громкости встроенной аудиодорожки"
  loudness=$(ffmpeg -i extracted_audio.aac -af "volumedetect" -f null /dev/null 2>&1 | grep "max_volume" | cut -d: -f2 | tr -d ' ')

  echo "Шаг 3: Умножение громкости на 0.1 (10%)"
  adjusted_loudness=$(bc -l <<< "$loudness * 0.1")

  echo "Шаг 4: Наложение встроенной аудиодорожки на вторую с учетом громкости"
  ffmpeg -i "$input_audio" -i extracted_audio.aac  -filter_complex "[0:a]volume=0.9[a1];[1:a]volume=0.1[a2];[a1][a2]amix=inputs=2:dropout_transition=2" mixed_audio.aac

  echo "Шаг 5: Кодировние видео с микшированной аудиодорожкой и добавлением субтитров"
  ffmpeg -hwaccel cuda -i "$input_video" -i mixed_audio.aac -i extracted_audio.aac -sub_charenc CP1250 -i "$input_subtitles"  -map 0:v -map 1:a -map 2:a -map 3:s -c:v h264_nvenc -b:v 300K -c:a aac -c:s mov_text -strict -2  -metadata:s:a:0 language=russian -metadata:s:a:1 language=english -metadata:s:s:0 language=english -disposition:s:0 default  "$output_file"

  echo "Шаг 6: Удаление временных аудиодорожек"
  rm extracted_audio.aac
  rm mixed_audio.aac
done

echo "Готово!"
```

>Скрип объединяет внешнюю дорожу в формате `mp3`, микширует звук с внутренней дорожкой (10% к 90%), добавляет в качестве первой звуковой дорожки нашу созданную, оставляя при этом существующую в качестве второй звуковой дорожки, формат аудио `aac`. Если встроенная дорожка отличается от формата `aac`, то она конвертируется в этот формат.
>Также добавляются субтитры на русском и английском языках (постфиксы \_eng, \_rus)
>Все происходит автоматически со всеми файлами в директории.
>Имена файлов берутся по имени видеофайла с расширением `mp4`.
```bash
#!/bin/bash

# Скрипт для автоматической обработки видеофайлов, включая извлечение аудио, микширование аудиодорожек,
# перекодирование аудио в AAC формат (если необходимо), и добавление субтитров на английском и русском языках.
# Итоговые файлы сохраняются в папку "Done".

output_directory="Done"

# Создание папки "Done," если её нет
mkdir -p "$output_directory"

for input_video in *.mp4; do
  input_filename="${input_video%.*}"  # Получаем имя файла без расширения
  input_audio="${input_filename}.mp3"
  input_subtitles_eng="${input_filename}_eng.srt"
  input_subtitles_rus="${input_filename}_rus.srt"
  output_file="$output_directory/${input_filename}.mp4"

  # Проверка, существует ли итоговый файл, если да, пропускаем кодирование
  if [ -f "$output_file" ]; then
    echo "Файл $output_file уже существует. Пропускаем кодирование."
    continue
  fi

  echo "Шаг 1: Извлечение аудиодорожки из видеофайла и проверка формата"
  audio_format=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$input_video")
  if [ "$audio_format" != "aac" ]; then
    echo "   Перекодировка аудио в AAC формат"
    ffmpeg -i "$input_video" -vn -acodec aac extracted_audio.aac
  else
    echo "   Аудио уже в AAC формате. Копирование..."
    ffmpeg -i "$input_video" -vn -acodec copy extracted_audio.aac
  fi

  echo "Шаг 2: Вычисление громкости встроенной аудиодорожки"
  loudness=$(ffmpeg -i extracted_audio.aac -af "volumedetect" -f null /dev/null 2>&1 | grep "max_volume" | cut -d: -f2 | tr -d ' ')

  echo "Шаг 3: Умножение громкости на 0.1 (10%)"
  adjusted_loudness=$(bc -l <<< "$loudness * 0.1")

  echo "Шаг 4: Наложение встроенной аудиодорожки на вторую с учетом громкости"
  ffmpeg -i "$input_audio" -i extracted_audio.aac  -filter_complex "[0:a]volume=0.9[a1];[1:a]volume=0.1[a2];[a1][a2]amix=inputs=2:dropout_transition=2" mixed_audio.aac

  echo "Шаг 5: Кодирование видео с микшированной аудиодорожкой и добавлением субтитров"
  ffmpeg -hwaccel cuda -i "$input_video" -i mixed_audio.aac -i extracted_audio.aac -i "$input_subtitles_eng" -i "$input_subtitles_rus" -map 0:v -map 1:a -map 2:a -map 3:s -map 4:s -c:v h264_nvenc -b:v 300K -c:a aac -c:s mov_text -metadata:s:a:0 language=russian -metadata:s:a:1 language=english -metadata:s:s:0 language=english -metadata:s:s:1 language=russian -disposition:s:0 default  "$output_file"

  echo "Шаг 6: Удаление временных аудиодорожек"
  rm extracted_audio.aac
  rm mixed_audio.aac
done

echo "Готово!"
```

>Скрипт скачивает по ссылке видеофайл на английском языке, к нему генерирует перевод на русском языке и субтитры на английском (посредством яндекс)
>Все смешивается и кладется в файл с именем которое задано по ссылке
```shell
#!/bin/bash

VERSION="1.1"

# Messages array for different languages
declare -A MESSAGES
MESSAGES=(

# English
["en_args"]="Args"
["en_args_bitrate"]="Set bitrate in Kbit"
["en_args_lang"]="Set translation language (en, ru, kk)"
["en_args_file"]="Set file with a list of links"
["en_args_orig"]="Set original language (en, ru, kk, zh, ko, ar, fr, it, es, de, ja)"
["en_args_subs"]="Set subtitles language"
["en_args_volume"]="Set volume ratio"
["en_bitrate"]="Bitrate"
["en_bitrate_error"]="Bitrate must be a number in the range of 50 to 20000"
["en_done"]="Done!"
["en_encoder"]="Encoder"
["en_examples"]="Examples"
["en_fail"]="Fail!"
["en_filename"]="Filename"
["en_invalid_param"]="Invalid option:"
["en_link"]="Link"
["en_link_required_error"]="Video link is required"
["en_loading_error"]="Error loading video."
["en_missing_dependencies"]="Error: The following dependencies are missing"
["en_options"]="Options"
["en_options_help"]="Show help"
["en_options_version"]="Show version"
["en_retrying"]="Retrying in 5 seconds... Attempt:"
["en_usage"]="Usage"
["en_volume"]="Original volume"
["en_volume_error"]="Volume ratio must be a number between 0 and 0.6"
["en_invalid_translate_language"]="Invalid translation language. Supported options are: en, ru, kk."
["en_invalid_source_language"]="Invalid source language. Supported options are: en, ru, kk, zh, ko, ar, fr, it, es, de, ja."

# Russian
["ru_args"]="Аргументы"
["ru_args_bitrate"]="Задать битрейт в Kbit"
["ru_args_lang"]="Задать язык перевода (en, ru, kk)"
["ru_args_file"]="Задать файл со списком ссылок"
["ru_args_orig"]="Задать исходный язык (en, ru, kk, zh, ko, ar, fr, it, es, de, ja)"
["ru_args_subs"]="Задать язык субтитров"
["ru_args_volume"]="Задать отношение громкости оригинала"
["ru_bitrate"]="Битрейт"
["ru_bitrate_error"]="Битрейт должен быть числом в диапазоне от 50 до 20000"
["ru_done"]="Готово!"
["ru_encoder"]="Энкодер"
["ru_examples"]="Примеры"
["ru_fail"]="Неудача!"
["ru_filename"]="Имя файла"
["ru_invalid_param"]="Неверный параметр:"
["ru_link"]="Ссылка"
["ru_link_required_error"]="Ссылка на видео является обязательной"
["ru_loading_error"]="Ошибка при загрузке видео"
["ru_missing_dependencies"]="Ошибка: Следующие зависимости не найдены"
["ru_options"]="Параметры"
["ru_options_help"]="Показать справку"
["ru_options_version"]="Показать версию"
["ru_retrying"]="Повторная попытка через 5 секунд... Попытка:"
["ru_usage"]="Использование"
["ru_volume"]="Громкость оригинала"
["ru_volume_error"]="Отношение громкости оригинала должно быть числом от 0 до 0.6"
["ru_invalid_translate_language"]="Неверный язык перевода. Допустимые варианты: en, ru, kk."
["ru_invalid_source_language"]="Неверный исходный язык. Допустимые варианты: en, ru, kk, zh, ko, ar, fr, it, es, de, ja."

# Kazakh
["kk_args"]="Аргументтер"
["kk_args_bitrate"]="Битрейтті Kbit түрінде орнату"
["kk_args_lang"]="Перевод тілін орнату (en, ru, kk)"
["kk_args_file"]="Қосымша сілтемелер тізімі бар файлды орнату"
["kk_args_orig"]="Бастапқы тілді орнату (en, ru, kk, zh, ko, ar, fr, it, es, de, ja)"
["kk_args_subs"]="Субтитр тілін орнату"
["kk_args_volume"]="Туындылық ұқсасын орнату"
["kk_bitrate"]="Битрейт"
["kk_bitrate_error"]="Битрейт 50-ден 20000-ге дейін сандық болуы керек"
["kk_done"]="Аяқталды!"
["kk_encoder"]="Коддаушы"
["kk_examples"]="Мысалдар"
["kk_fail"]="Сәтсіздік!"
["kk_filename"]="Файл атауы"
["kk_invalid_param"]="Жарамсыз опция:"
["kk_link"]="Сілтеме"
["kk_link_required_error"]="Видео сілтемесі қажет"
["kk_loading_error"]="Видео жүктеу кезінде қате."
["kk_missing_dependencies"]="Қате: келесі қолжетімділіктер жоқ"
["kk_options"]="Опциялар"
["kk_options_help"]="Көмек көрсету"
["kk_options_version"]="Нұсқасын көрсету"
["kk_retrying"]="5 секундтан кейін қайталап алу... Сынақ:"
["kk_usage"]="Қолдану"
["kk_volume"]="Орындық туындылығы"
["kk_volume_error"]="Орындық туындылығы 0 мен 0,6 аралығында сандық болуы керек"
["kk_invalid_translate_language"]="Қате аударма тілі. Толықтыру үшін қолданылатын тілдер: en, ru, kk."
["kk_invalid_source_language"]="Қате бастапқы тіл. Толықтыру үшін қолданылатын тілдер: en, ru, kk, zh, ko, ar, fr, it, es, de, ja."
)

# Checking the availability of a translation for the original language
if [[ -n "${MESSAGES[$(echo $LANG | cut -d '_' -f1)_args]}" ]]; then
    lang_app=$(echo $LANG | cut -d '_' -f1)
else
    lang_app="en"
fi

# Check if required dependencies are installed
dependencies=("yt-dlp" "vot-cli" "jq" "ffmpeg" "ffprobe")
missing_dependencies=()

for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        missing_dependencies+=("$dep")
    fi
done

if [ ${#missing_dependencies[@]} -ne 0 ]; then
    echo "${MESSAGES[${lang_app}_missing_dependencies]} ${missing_dependencies[*]}"
    exit 1
fi

translation_lang="--reslang=ru"
subs_lang="--reslang=en"

# Function to parse command line arguments
parse_args() {
    usage() {
        echo -e "\e[1myvt\e[0m — Yandex Video Translate v$VERSION\n"
        echo -e "\e[1m${MESSAGES[${lang_app}_usage]}:\e[0m"
        echo -e "  yvt [options] [args] <link>\n"
        echo -e "\e[1m${MESSAGES[${lang_app}_args]}:\e[0m"
        echo -e "  -v — ${MESSAGES[${lang_app}_args_volume]}"
        echo -e "  -b — ${MESSAGES[${lang_app}_args_bitrate]}"
        echo -e "  -f — ${MESSAGES[${lang_app}_args_file]}"
        echo -e "  -o — ${MESSAGES[${lang_app}_args_orig]}"
        echo -e "  -l — ${MESSAGES[${lang_app}_args_lang]}"
        echo -e "  -s — ${MESSAGES[${lang_app}_args_subs]}\n"
        echo -e "\e[1m${MESSAGES[${lang_app}_options]}:\e[0m"
        echo -e "  --help — ${MESSAGES[${lang_app}_options_help]}"
        echo -e "  --version — ${MESSAGES[${lang_app}_options_version]}\n"
        echo -e "\e[1m${MESSAGES[${lang_app}_examples]}:\e[0m"
        echo -e "  yvt -v 0.5 -b 800 'https://www.youtube.com/watch?v=example_video'"
        echo -e "  yvt -v .2 -b 500 -f ./linklist.txt"
    }

    # Check the number of arguments passed
    if [ $# -eq 0 ]; then
        usage
        exit 1
    fi

    while getopts ":v:b:f:o:l:s:-:" opt; do
        case ${opt} in
            v )
                # Check if the entered value is in the valid range
                if [[ ! $OPTARG =~ ^(\.[0-9]+|[0-9]+(\.[0-9]*)?)$ ]]; then
                    echo "${MESSAGES[${lang_app}_volume_error]}" 1>&2
                    exit 1
                fi
                if (( $(awk 'BEGIN { print ('$OPTARG' < 0.0 || '$OPTARG' > 0.6) }') )); then
                    echo "${MESSAGES[${lang_app}_volume_error]}" 1>&2
                    exit 1
                fi
                original_sound_ratio=$OPTARG
                ;;
            b )
                # Check if the bitrate is a valid number within the specified range
                if [[ ! $OPTARG =~ ^[0-9]+$ ]]; then
                    echo "${MESSAGES[${lang_app}_bitrate_error]}" >&2
                    exit 1
                fi
                if ((OPTARG < 50 || OPTARG > 20000)); then
                    echo "${MESSAGES[${lang_app}_bitrate_error]}" >&2
                    exit 1
                fi
                bitrate=$OPTARG
                ;;
            f )
                file_input=$OPTARG
                if [ ! -f "$file_input" ]; then
                    echo "${MESSAGES[${lang_app}_file_not_exist_error]}" >&2
                    exit 1
                fi
                exec 3< "$file_input"
                while IFS= read -r line <&3; do
                    parse_link "$line"
                    echo "$line"
                done
                exec 3<&-
                exit 0
                ;;
            l )
                if [[ ! "$OPTARG" =~ ^(en|ru|kk)$ ]]; then
                    echo "${MESSAGES[${lang_app}_invalid_translate_language]}" >&2
                    exit 1
                fi
                translation_lang="--reslang="$OPTARG
                ;;
            s )
                if [[ ! "$OPTARG" =~ ^(en|ru|kk|zh|ko|ar|fr|it|es|de|ja)$ ]]; then
                    echo "${MESSAGES[${lang_app}_invalid_translate_language]}" >&2
                    exit 1
                fi
                subs_lang="--reslang="$OPTARG
                ;;
            o )
                if [[ ! "$OPTARG" =~ ^(en|ru|kk|zh|ko|ar|fr|it|es|de|ja)$ ]]; then
                    echo "${MESSAGES[${lang_app}_invalid_source_language]}" >&2
                    exit 1
                fi
                original_lang=$OPTARG
                ;;
            - )
                case "${OPTARG}" in
                    help )
                        usage
                        exit 0
                        ;;
                    version )
                        echo "Yandex Video Translate v$VERSION"
                        exit 0
                        ;;
                    * )
                        echo "${MESSAGES[${lang_app}_invalid_param]} --$OPTARG" 1>&2
                        exit 1
                        ;;
                esac
                ;;
            \? )
                echo "${MESSAGES[${lang_app}_invalid_param]} $OPTARG" 1>&2
                exit 1
                ;;
            : )
                echo "${MESSAGES[${lang_app}_invalid_param]} $OPTARG" 1>&2
                exit 1
                ;;
        esac
    done

    shift $((OPTIND -1))
    video_link="${@: -1}"
    parse_link "$video_link"

    if [ -z "$video_link" ]; then
        echo "${MESSAGES[${lang_app}_link_required_error]}"
        usage
        exit 1
    fi
}

# Function to process each linkcess each link
parse_link() {
    video_link="$1"
    tput cuu1
    tput el
    echo -e "🔗 ${MESSAGES[${lang_app}_link]}: \e[1m$video_link\e[0m"

    if nvidia-smi &> /dev/null; then
        cuda="-hwaccel cuda -hwaccel_output_format cuda"
    fi

    video_codec="libx264"
    if lspci | grep -iE "vga.*nvidia|nvidia.*vga" &> /dev/null; then
        video_codec="h264_nvenc"
    elif lspci | grep -iE "vga.*amd|amd.*vga" &> /dev/null; then
        video_codec="libx264"
    elif lspci | grep -iE "vga.*intel|intel.*vga" &> /dev/null; then
        video_codec="libx264"
    fi

    original_sound_ratio=${original_sound_ratio:-0.3}
    bitrate=${bitrate:-450}
    temp_dir=./temp
    temp_video_dir=$temp_dir/video
    temp_audio_dir=$temp_dir/audio
    temp_subs_dir=$temp_dir/subtitles
    temp_video="$temp_video_dir/%(title)s"

    if [ -d "$temp_dir" ]; then
        rm -rf "$temp_dir"
    fi

    mkdir $temp_dir && mkdir $temp_video_dir && mkdir $temp_audio_dir && mkdir $temp_subs_dir

    attempts=0
    while ! yt-dlp --progress --quiet -o "$temp_video" $video_link  && (( attempts < 10 )); do
        (( attempts++ ))
        echo "${MESSAGES[${lang_app}_loading_error]} ${MESSAGES[${lang_app}_retrying]}$attempts"
        sleep 5
    done

    NODE_OPTIONS='--no-deprecation' vot-cli --output=$temp_audio_dir $translation_lang $video_link> /dev/null
    NODE_OPTIONS='--no-deprecation' vot-cli --output=$temp_subs_dir --subs $subs_lang $video_link> /dev/null

    subs_full_name=$(find $temp_subs_dir -type f | head -n 1)

jq -r '.subtitles[] | select((.text | test("\\[\\s*( Music)\\s*\\]", "i") | not)) | (.text | rtrimstr(".") | split(". ")[]) as $sentence | "0\n" +
    (.startMs / 1000 | floor | gmtime | strftime("%H:%M:%S")) + "." + ((.startMs % 1000) / 10 | floor | tostring) +
    " --> " + ((.startMs / 1000 + .durationMs / 1000) | floor | gmtime | strftime("%H:%M:%S")) + "." +
    (((.startMs + .durationMs) % 1000) / 10 | floor | tostring) + "\n" + $sentence + "\n"' $subs_full_name > "$subs_full_name".srt

    video_full_name=$(basename "$(find "$temp_video_dir" -type f | head -n 1)")

    echo -e "🔊 ${MESSAGES[${lang_app}_volume]}: \e[1m$original_sound_ratio\e[0m"
    echo -e "📈 ${MESSAGES[${lang_app}_bitrate]}: \e[1m$bitrate Kbit\e[0m"
    echo -e "📹 ${MESSAGES[${lang_app}_encoder]}: \e[1m$video_codec\e[0m"
    echo -e "📄 ${MESSAGES[${lang_app}_filename]}: \e[1m"${video_full_name%.*}.mp4"\e[0m"

    source_video_codec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$(find "$temp_video_dir" -type f | head -n 1)")
    source_audio_codec=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$(find "$temp_video_dir" -type f | head -n 1)")

    if [ "$source_video_codec" != "h264" ] || [ "$source_audio_codec" != "aac" ]; then
    ffmpeg \
        $cuda \
        -hide_banner -v quiet -stats\
        -i "$temp_video_dir/$video_full_name" \
        -c:v $video_codec -b:v "$bitrate"K -crf 23 -preset medium -c:a aac \
        "$temp_video_dir/${video_full_name%.*}".mp4

        tput cuu1
        tput el

        rm "$temp_video_dir/$video_full_name"
        video_full_name=$(basename "$(find "$temp_video_dir" -type f | head -n 1)")
        video_codec="copy"
    fi


if ffmpeg \
        $cuda \
        -hide_banner -v quiet -stats \
        -i $temp_video_dir/* -i $temp_audio_dir/* -i "$subs_full_name".srt \
        -c:v $video_codec -b:v "$bitrate"K -crf 23 -preset medium \
        -filter_complex "[0:a] volume=$original_sound_ratio [original]; \
        [original][1:a] amix=inputs=2:duration=longest [mixed_audio]; \
        [0:a] volume=1 [original_audio]" \
        -map 0:v -map "[mixed_audio]" -map "[original_audio]" -map 2:s \
        -c:s mov_text -metadata:s:a:0 language=russian -metadata:s:a:1 language=english -metadata:s:s:0 language=english \
        -y "$video_full_name"; then

    tput cuu1
    tput el

    echo -e "👍 ${MESSAGES[${lang_app}_done]}"
    echo
else
    echo -e "❌ ${MESSAGES[${lang_app}_fail]}"
    echo
fi
    rm -r $temp_dir
}

# Parse command line arguments
parse_args "$@"
```

>Переименование файлов с лидирующими нулями
```shell
#!/bin/bash

# Проверяем, передан ли аргумент командной строки
if [ "$#" -ne 1 ]; then
    echo "Использование: $0 <путь_к_каталогу>"
    exit 1
fi

# Путь к каталогу с файлами
directory="$1"

# Проверяем существование каталога
if [ ! -d "$directory" ]; then
    echo "Каталог '$directory' не существует."
    exit 1
fi

# Получаем список файлов в каталоге (включая файлы с пробелами)
mapfile -t files < <(find "$directory" -maxdepth 1 -type f -printf "%f\n")

# Определяем максимальную разрядность числового префикса
max_digits=0
for filename in "${files[@]}"; do
    prefix=$(echo "$filename" | grep -o '^[0-9]*')
    if [[ $prefix =~ ^[0-9]+$ ]]; then
        prefix_length=${#prefix}
        if (( prefix_length > max_digits )); then
            max_digits=$prefix_length
        fi
    fi
done

# Переименовываем файлы, добавляя лидирующие нули
for filename in "${files[@]}"; do
    prefix=$(echo "$filename" | grep -o '^[0-9]*')
    if [[ $prefix =~ ^[0-9]+$ ]]; then
        prefix_length=${#prefix}
        # Проверяем, нужно ли переименовывать файл
        if (( prefix_length < max_digits )); then
            padded_prefix=$(printf "%0${max_digits}d" "$prefix")
            new_filename=$(echo "$filename" | sed "s/^$prefix/$padded_prefix/")
            mv "$directory/$filename" "$directory/$new_filename"
        fi
    fi
done
```