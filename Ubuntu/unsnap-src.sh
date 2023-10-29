#!/bin/bash

# Получаем версию Ubuntu
ubuntu_version=$(lsb_release -rs)

# Функция для очистки от Snap
function clean_snap {
  sudo apt purge snapd -y
  sudo rm -rf /var/snap /snap
  sudo apt autoremove
  sudo apt clean

  echo "package snapd hold" | sudo dpkg --set-selections
  echo "package snapd from snapd:amd64 hold" | sudo dpkg --set-selections
  echo "package snapd from snapd:arm64 hold" | sudo dpkg --set-selections

  echo -e "Package: snapd\nPin: origin ''\nPin-Priority: -1" | sudo tee /etc/apt/preferences.d/nosnap.pref

  echo "Система очищена от Snap"
}

# Функция для установки Firefox из PPA
function install_firefox {
  read -p "Выберите версию Firefox (1 - Стабильная, 2 - Бета): " choice

  case $choice in
    1)
      repo="ppa:mozillateam/ppa"
      ;;
    2)  
      repo="ppa:mozillateam/firefox-next"
      ;;
    *)
      echo "Неверный выбор"
      return 1
      ;;
  esac

  sudo add-apt-repository $repo
  echo "PPA репозиторий mozillateam добавлен"

  echo 'Package: *
  Pin: release o=LP-PPA-mozillateam
  Pin-Priority: 1001' | sudo tee /etc/apt/preferences.d/mozilla-firefox

  sudo apt update
  sudo apt install firefox
  
  echo "Firefox установлен"  
}

read -p "Очистить от Snap? (y/n) " choice
if [[ $confirm =~ ^[yY]$ ]]; then
  clean_snap
fi

read -p "Устанновть Firefox из PPA? (y/n) " choice  
if [[ $confirm =~ ^[yY]$ ]]; then
  install_firefox
fi
