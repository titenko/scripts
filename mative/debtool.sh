#!/bin/bash
set -euo pipefail

# Цвета для вывода
COLOR_INFO="\033[1;32m"
COLOR_ERROR="\033[1;31m"
COLOR_RESET="\033[0m"

log() {
  echo -e "${COLOR_INFO}[INFO]${COLOR_RESET} $*"
}

error() {
  echo -e "${COLOR_ERROR}[ERROR]${COLOR_RESET} $*" >&2
}

check_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    error "Команда '$1' не найдена. Пожалуйста, установите её и повторите."
    exit 1
  fi
}

unpack_deb() {
  local deb_file="$1"
  local folder="$2"

  if [ ! -f "$deb_file" ]; then
    error "Файл '$deb_file' не найден."
    exit 1
  fi

  if [ -e "$folder" ] && [ ! -d "$folder" ]; then
    error "'$folder' существует и не является директорией."
    exit 1
  fi

  mkdir -p "$folder"
  dpkg-deb -R "$deb_file" "$folder"
  log "Пакет '$deb_file' успешно распакован в папку '$folder'."
}

pack_deb() {
  local folder="$1"
  local deb_file="$2"

  if [ ! -d "$folder" ]; then
    error "Папка '$folder' не найдена."
    exit 1
  fi

  dpkg-deb -b "$folder" "$deb_file"
  log "Пакет '$deb_file' успешно упакован из папки '$folder'."
}

build_deb() {
  local src_folder="$1"

  if [ ! -d "$src_folder" ]; then
    error "Папка '$src_folder' не найдена."
    exit 1
  fi

  if [ ! -f "$src_folder/debian/control" ]; then
    error "В папке '$src_folder' не найден файл debian/control — это обязательно для сборки."
    exit 1
  fi

  log "Обновляю списки пакетов и устанавливаю необходимые инструменты..."
  sudo apt update
  sudo apt install -y --no-install-recommends equivs devscripts

  log "Устанавливаю build-deps для проекта..."
  mk-build-deps -i -t "apt-get --yes" -r

  log "Начинаю сборку пакета..."
  cd "$src_folder"
  dpkg-buildpackage -b -uc -us
  log "Сборка пакета завершена."
}

main() {
  check_command dpkg-deb
  check_command mk-build-deps
  check_command dpkg-buildpackage

  echo "Выберите действие:"
  echo "1. Распаковка deb"
  echo "2. Упаковка deb"
  echo "3. Сборка deb"
  read -rp "Введите номер действия: " action

  case "$action" in
    1)
      read -rp "Введите название deb-пакета (с расширением .deb): " pname
      read -rp "Введите название папки для распаковки: " folder_name
      unpack_deb "$pname" "$folder_name"
      ;;
    2)
      read -rp "Введите название папки для упаковки: " folder_name
      read -rp "Введите имя итогового deb-пакета (с расширением .deb): " pname
      pack_deb "$folder_name" "$pname"
      ;;
    3)
      read -rp "Введите название папки с исходным кодом: " src_folder
      build_deb "$src_folder"
      ;;
    *)
      error "Некорректный выбор действия."
      exit 1
      ;;
  esac
}

main

