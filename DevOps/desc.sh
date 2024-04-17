#!/bin/bash

# Проверяем, передан ли путь к файлу в качестве аргумента
if [ $# -ne 1 ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

file="$1"

# Проверяем, существует ли файл
if [ ! -f "$file" ]; then
    echo "File '$file' not found."
    exit 1
fi

# Перебираем строки файла
while IFS= read -r line; do
    # Ищем конструкции вида ![|size](url)
    if [[ "$line" =~ \!\[\|[0-9]+\]\(.*\) ]]; then
        # Получаем ссылку на изображение и размер
        url="${BASH_REMATCH[1]}"
        size="${BASH_REMATCH[0]#*|}"
        size="${size%]*}"

        # Извлекаем имя файла из ссылки
        filename="${url##*/}"

        # Удаляем расширение файла
        filename="${filename%.*}"

        # Формируем новую строку с обновленным описанием
        new_line="![${filename}|${size}](${url})"

        # Заменяем строку в файле, используя разделитель sed '|'
        sed -i "s|${BASH_REMATCH[0]}|${new_line}|g" "$file"
    fi
done < "$file"

echo "Descriptions updated successfully."
