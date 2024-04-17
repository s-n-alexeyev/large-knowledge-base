#!/bin/bash

# Проверяем, что передан аргумент с именем файла
if [ $# -eq 0 ]; then
    echo "Usage: $0 filename"
    exit 1
fi

# Перебираем строки файла и обрабатываем каждую
while IFS= read -r line; do
    # Проверяем, что строка содержит ссылку на изображение
    if [[ $line =~ \!\[\|\[0-9]+ ]]; then
        # Извлекаем имя файла из ссылки
        filename=$(echo "$line" | sed -n 's/.*(\(.*\))/\1/p')

        # Извлекаем описание и размер из строки
        description=$(echo "$line" | sed -n 's/.*\[\(.*\)\](.*)/\1/p')
        size=$(echo "$description" | sed -n 's/.*|\([0-9]*\)/\1/p')

        # Формируем новую строку с описанием и размером
        new_line="![${filename}|${size}]($filename)"

        # Заменяем строку в файле
        sed -i "s@$line@$new_line@" "$1"
    fi
done < "$1"
