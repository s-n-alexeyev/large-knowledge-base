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

# Проверка наличия зависимостей
dependencies=("yt-dlp" "vot-cli" "jq" "ffmpeg" "ffprobe")
missing_dependencies=()

for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        missing_dependencies+=("$dep")
    fi
done

if [ ${#missing_dependencies[@]} -ne 0 ]; then
    case "$LANG" in
        ru_RU.UTF-8)
            echo "Ошибка: Следующие зависимости не найдены: ${missing_dependencies[*]}"
            ;;
        *)
            echo "Error: The following dependencies are missing: ${missing_dependencies[*]}"
            ;;
    esac
    exit 1
fi

if nvidia-smi &> /dev/null; then
    cuda="-hwaccel cuda -hwaccel_output_format cuda"
else
    cuda=""
fi

# Проверка наличия поддерживаемых ускорителей
if   lspci | grep -iE "vga.*nvidia|nvidia.*vga" &> /dev/null; then
    # Если доступен NVIDIA GPU, используем h264_nvenc
    video_codec="h264_nvenc"
elif lspci | grep -iE "vga.*amd|amd.*vga" &> /dev/null; then
    # Если обнаружено устройство с графическим процессором AMD, используем h264_vdpau
    video_codec="libx264"
elif lspci | grep -iE "vga.*intel|intel.*vga" &> /dev/null; then
    # Если обнаружено устройство с графическим процессором Intel, используем h264_vaapi
    video_codec="libx264"
else
    # Если ни один из ускорителей не доступен, используем libx264
    video_codec="libx264"
fi

# Проверка аргумента --help или отсутствия параметров
if [[ "$1" == "--help" ]] || [ -z "$1" ]; then
    case "$LANG" in
        ru_RU.UTF-8)
            echo "Документация:"
            echo "Этот скрипт загружает видео, переводит его, загружает субтитры и смешивает все вместе."
            echo "Использование:"
            echo "sh translate.sh <ссылка на видео> [отношение громкости оригинала] [битрейт в kb] [--help]"
            echo "Примеры:"
            echo "sh translate.sh https://www.youtube.com/watch?v=example_video 0.5 800"
            echo "sh translate.sh https://www.youtube.com/watch?v=example_video"
            ;;
        *)
            echo "Documentation:"
            echo "This script downloads a video, translates it, downloads subtitles, and mixes them all together."
            echo "Usage:"
            echo "sh translate.sh <video link> [volume ratio] [bitrate in kb] [--help]"
            echo "Examples:"
            echo "sh translate.sh https://www.youtube.com/watch?v=example_video 0.5 800"
            echo "sh translate.sh https://www.youtube.com/watch?v=example_video"
            ;;
    esac
    exit 0
fi

# Устанавливаем настройки по умолчанию
original_sound_ratio=0.3
bitrate=450
temp_dir=./temp # будет удалено командой rm -r
temp_video_dir=$temp_dir/video
temp_audio_dir=$temp_dir/audio
temp_subs_dir=$temp_dir/subtitles
temp_video="$temp_video_dir/%(title)s"

# Получаем ссылку на видео из аргументов командной строки
video_link=$1

# Если предоставлены дополнительные параметры, используем их
if [ -n "$2" ]; then
    original_sound_ratio=$2
fi

if [ -n "$3" ]; then
    bitrate=$3
fi

# Проверяем, доступен ли ffpb, иначе используем ffmpeg
if command -v ffpb &> /dev/null; then
    ffmpeg_command="ffpb"
elif command -v ffmpeg &> /dev/null; then
    ffmpeg_command="ffmpeg"
else
    echo "Error: Neither FFmpeg nor ffmpeg found in the system."
    exit 1
fi

# Создаем временные директории
mkdir $temp_dir && mkdir $temp_video_dir && mkdir $temp_audio_dir && mkdir $temp_subs_dir

# Загружаем видео, аудио и субтитры
yt-dlp -o "$temp_video" $video_link
vot-cli --output=$temp_audio_dir $video_link > /dev/null && vot-cli --output=$temp_subs_dir --subs --reslang=en $video_link > /dev/null

# Извлекаем имя файла субтитров
subs_full_name=$(find $temp_subs_dir -type f | head -n 1)

# Преобразуем субтитры в формат SRT
jq -r '.subtitles[] | (.text | rtrimstr(".") | split(". ")[]) as $sentence | "\(.speakerId)\n" +
    (.startMs / 1000 | floor | gmtime | strftime("%H:%M:%S")) + "." + ((.startMs % 1000) / 10 | floor | tostring) +
    " --> " + ((.startMs / 1000 + .durationMs / 1000) | floor | gmtime | strftime("%H:%M:%S")) + "." +
    (((.startMs + .durationMs) % 1000) / 10 | floor | tostring) + "\n" + $sentence + "\n"' $subs_full_name > "$subs_full_name".srt

# Выводим информацию
case "$LANG" in
    ru_RU.UTF-8)
        echo -e 🔊 "\e[1mГромкость оригинала установлена на $original_sound_ratio\e[0m"
        echo -e 📈 "\e[1mБитрейт выставлен на $bitrate kb\e[0m"
        echo -e 📹 "\e[1mИспользуется видеокодек $video_codec\e[0m"
        ;;
    *)
        echo -e 🔊 "\e[1mOriginal volume is set to $original_sound_ratio\e[0m"
        echo -e 📈 "\e[1mBitrate is set to $bitrate kb\e[0m"
        echo -e 📹 "\e[1mVideo codec is use $video_codec\e[0m"
        ;;
esac

# Извлекаем имя файла видео
video_full_name=$(basename "$(find "$temp_video_dir" -type f | head -n 1)")

# Проверяем кодеки видео и аудио
source_video_codec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$(find "$temp_video_dir" -type f | head -n 1)")
source_audio_codec=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$(find "$temp_video_dir" -type f | head -n 1)")

# Выбираем кодек для объединения звука и видео
if [ "$source_video_codec" != "h264" ] || [ "$source_audio_codec" != "aac" ]; then
    $ffmpeg_command \
        $cuda \
        -i "$temp_video_dir/$video_full_name" \
        -c:v $video_codec -b:v "$bitrate"K -c:a aac \
        "$temp_video_dir/${video_full_name%.*}".mp4

        rm "$temp_video_dir/$video_full_name"
        video_full_name=$(basename "$(find "$temp_video_dir" -type f | head -n 1)")
        video_codec="copy"
fi

# Объединяем видео, аудио и субтитры
$ffmpeg_command \
    $cuda \
    -i $temp_video_dir/* -i $temp_audio_dir/* \
    -i "$subs_full_name".srt \
    -c:v $video_codec -b:v "$bitrate"K \
    -filter_complex "[0:a] volume=$original_sound_ratio [original]; \
    [original][1:a] amix=inputs=2:duration=longest [mixed_audio]; \
    [0:a] volume=1 [original_audio]" \
    -map 0:v -map "[mixed_audio]" -map "[original_audio]" -map 2:s \
    -c:s mov_text -metadata:s:a:0 language=russian -metadata:s:a:1 language=english -metadata:s:s:0 language=english \
    -y "$video_full_name"

# Удаляем временные директории
rm -r $temp_dir
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