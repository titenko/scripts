#!/bin/bash

set -e

install_package() {
  local pkg=$1
  if ! command -v "$pkg" &>/dev/null; then
    echo "Пакет '$pkg' не найден. Попробовать установить? (y/n)"
    read -r ans
    if [[ "$ans" == "y" ]]; then
      echo "Устанавливаем $pkg..."
      sudo apt-get update
      sudo apt-get install -y "$pkg"
      if ! command -v "$pkg" &>/dev/null; then
        echo "Не удалось установить $pkg. Выход."
        exit 1
      fi
    else
      echo "Необходимо установить $pkg. Выход."
      exit 1
    fi
  fi
}

format_and_check_script() {
  local file=$1

  echo "Проверка синтаксиса скрипта..."
  if ! bash -n "$file"; then
    echo "Обнаружены ошибки синтаксиса! Исправьте их и попробуйте снова."
    exit 1
  else
    echo "Синтаксис проверен — ошибок не найдено."
  fi

  # Проверка shellcheck
  if ! command -v shellcheck &>/dev/null; then
    echo "Утилита shellcheck не найдена. Хотите установить? (y/n)"
    read -r ans
    if [[ "$ans" == "y" ]]; then
      sudo apt-get update
      sudo apt-get install -y shellcheck
    else
      echo "Пропускаем анализ с помощью shellcheck."
      return
    fi
  fi

  echo "Запускаем shellcheck для анализа скрипта..."
  shellcheck "$file" && echo "shellcheck завершён без ошибок." || echo "shellcheck нашёл предупреждения/ошибки."

  read -rp "Хотите попробовать автоматически исправить ошибки с помощью shellcheck? (y/n): " fix_ans
  if [[ "$fix_ans" == "y" ]]; then
    # shellcheck --fix появился в версии >= 0.8.0
    if shellcheck --version | grep -q '^version: [0-9]\+\.[89]\|^[0-9]\+\.[1-9][0-9]\+'; then
      echo "Автоматическое исправление..."
      shellcheck --fix "$file"
      echo "Исправления применены."
    else
      echo "Ваша версия shellcheck не поддерживает --fix. Обновите shellcheck для этой функции."
    fi
  fi

  # Проверка shfmt
  if ! command -v shfmt &>/dev/null; then
    echo "Утилита shfmt не найдена. Хотите установить? (y/n)"
    read -r ans
    if [[ "$ans" == "y" ]]; then
      sudo apt-get update
      sudo apt-get install -y shfmt
    else
      echo "Форматирование пропущено."
      return
    fi
  fi

  echo "Форматирование скрипта с помощью shfmt..."
  shfmt -w "$file"
  echo "Форматирование завершено."
}

echo "=== Преобразование .sh скрипта в исполняемый файл ==="
read -rp "Введите путь к вашему скрипту (.sh): " SCRIPT_PATH

if [[ ! -f "$SCRIPT_PATH" ]]; then
  echo "Ошибка: файл не найден."
  exit 1
fi

echo "Выберите действие:"
echo "1) Сделать скрипт исполняемым и переместить в /usr/local/bin (или указанную папку)"
echo "2) Скомпилировать скрипт в бинарник с помощью shc"
echo "3) Создать самораспаковывающийся исполняемый архив с помощью makeself"
echo "4) Проверить, проанализировать (shellcheck), автоматически исправить и отформатировать скрипт (.sh)"
echo "0) Выход"

read -rp "Введите номер варианта: " OPTION

case "$OPTION" in
  1)
    read -rp "Введите имя исполняемого файла (без пути): " EXEC_NAME
    if [[ -z "$EXEC_NAME" ]]; then
      EXEC_NAME=$(basename "$SCRIPT_PATH" .sh)
      echo "Используется имя: $EXEC_NAME"
    fi
    read -rp "Введите путь для установки (по умолчанию /usr/local/bin): " INSTALL_DIR
    INSTALL_DIR=${INSTALL_DIR:-/usr/local/bin}

    if [[ ! -d "$INSTALL_DIR" ]]; then
      echo "Папка $INSTALL_DIR не существует. Создать? (y/n)"
      read -r CREATE_DIR
      if [[ "$CREATE_DIR" == "y" ]]; then
        sudo mkdir -p "$INSTALL_DIR"
      else
        echo "Отмена."
        exit 1
      fi
    fi

    chmod +x "$SCRIPT_PATH"
    sudo cp "$SCRIPT_PATH" "$INSTALL_DIR/$EXEC_NAME"
    echo "Скрипт установлен как исполняемый файл в $INSTALL_DIR/$EXEC_NAME"
    ;;

  2)
    install_package shc

    read -rp "Введите имя для бинарника (без пути): " BIN_NAME
    BIN_NAME=${BIN_NAME:-$(basename "$SCRIPT_PATH" .sh)}

    shc -f "$SCRIPT_PATH" -o "$BIN_NAME"
    echo "Бинарник создан: $BIN_NAME"
    read -rp "Хотите установить бинарник в /usr/local/bin? (y/n): " INSTALL_BIN
    if [[ "$INSTALL_BIN" == "y" ]]; then
      sudo cp "$BIN_NAME" /usr/local/bin/
      sudo chmod +x /usr/local/bin/"$BIN_NAME"
      echo "Бинарник установлен в /usr/local/bin/$BIN_NAME"
    fi
    ;;

  3)
    install_package makeself

    read -rp "Введите имя для создаваемого архива (без расширения): " ARCHIVE_NAME
    ARCHIVE_NAME=${ARCHIVE_NAME:-$(basename "$SCRIPT_PATH" .sh)}

    read -rp "Введите описание для архива (опционально): " ARCHIVE_DESC

    makeself --notemp . "$ARCHIVE_NAME.run" "$ARCHIVE_DESC" "./$(basename "$SCRIPT_PATH")"
    echo "Самораспаковывающийся архив создан: $ARCHIVE_NAME.run"
    read -rp "Хотите установить архив в /usr/local/bin? (y/n): " INSTALL_RUN
    if [[ "$INSTALL_RUN" == "y" ]]; then
      sudo cp "$ARCHIVE_NAME.run" /usr/local/bin/
      sudo chmod +x /usr/local/bin/"$ARCHIVE_NAME.run"
      echo "Архив установлен в /usr/local/bin/$ARCHIVE_NAME.run"
    fi
    ;;

  4)
    format_and_check_script "$SCRIPT_PATH"
    ;;

  0)
    echo "Выход."
    exit 0
    ;;

  *)
    echo "Неверный вариант."
    exit 1
    ;;
esac

