
> Делаем из PDF один длинный PNG
```shell
#!/bin/bash

# Проверка аргумента
if [ -z "$1" ]; then
  echo "Usage: $0 input.pdf"
  exit 1
fi

INPUT_PDF="$1"
BASENAME=$(basename "$INPUT_PDF" .pdf)
TMP_DIR="./tmp_${BASENAME}_img"
OUTPUT_IMG="${BASENAME}_vertical.png"

# Проверка наличия утилит
command -v pdftoppm >/dev/null 2>&1 || { echo >&2 "pdftoppm не установлен. Установи через: sudo pacman -S poppler-utils"; exit 1; }
command -v convert >/dev/null 2>&1 || { echo >&2 "ImageMagick (convert) не установлен. Установи через: sudo pacman -S imagemagick"; exit 1; }

# Создание временной папки
mkdir -p "$TMP_DIR"

echo "Конвертация PDF в PNG..."
pdftoppm -png "$INPUT_PDF" "$TMP_DIR/page"

echo "Объединение изображений..."
convert "$TMP_DIR"/page-*.png -append "$OUTPUT_IMG"

echo "Удаление временных файлов..."
rm -r "$TMP_DIR"

echo "✅ Готово! Результат: $OUTPUT_IMG"

```

---

