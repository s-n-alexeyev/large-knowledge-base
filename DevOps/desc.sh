#!/bin/bash

# Проверяем, передан ли файл как аргумент командной строки
if [ $# -eq 0 ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

# Переменная, содержащая имя файла
file="$1"

# Проверяем, существует ли указанный файл
if [ ! -f "$file" ]; then
    echo "File $file not found"
    exit 1
fi

# Ищем внешние ссылки в файле
external_links=$(grep -oP '!\[\|\d+\]\(\K[^)]+' "$file")

# Обрабатываем каждую найденную внешнюю ссылку
while IFS= read -r link; do
    # Получаем имя файла из ссылки
    file_name=$(basename "$link")

    # Удаляем расширение из имени файла
    file_name="${file_name%.*}"

    # Заменяем пробелы и %20 на подчеркивания
    file_name=$(echo "$file_name" | sed 's/ /_/g' | sed 's/%20/_/g')

    # Добавляем описание файла к ссылке
    sed -i "s|\($link\)|\[\|$file_name\|${BASH_REMATCH[1]}\]|g" "$file"
done <<< "$external_links"

echo "Descriptions added to external links in $file"

