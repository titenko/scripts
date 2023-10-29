#!/bin/bash

# Получаем версию Ubuntu
ubuntu_version=$(lsb_release -rs)

read -p "Хотите очистить систему от Snap? (1 - Да, 2 - Нет): " clean_snap_choice
if [ "$clean_snap_choice" == "1" ]; then

# Удаляем пакеты snapd
sudo apt purge snapd -y

# Удаляем остаточные файлы snap
sudo rm -rf /var/snap
sudo rm -rf /snap

# Очищаем кеш
sudo apt autoremove
sudo apt clean

# Блокируем установку snapd с помощью dpkg
echo "package snapd hold" | sudo dpkg --set-selections
echo "package snapd from snapd:amd64 hold" | sudo dpkg --set-selections
echo "package snapd from snapd:arm64 hold" | sudo dpkg --set-selections

# Блокируем установку snapd с помощью APT
echo -e "Package: snapd\nPin: origin ''\nPin-Priority: -1" | sudo tee /etc/apt/preferences.d/nosnap.pref

# Опционально, можно также удалить пакеты snapd, оставшиеся в списке
# sudo apt-mark hold snapd

echo "Система успешно очищена от Snap."

 read -p "Хотите добавить PPA репозиторий и установить Firefox из PPA? (1 - Да, 2 - Нет): " install_firefox_choice
    if [ "$install_firefox_choice" == "1" ]; then

# Запрашиваем у пользователя выбор между стабильной и бета-версией Firefox
while true; do
    read -p "Выберите версию Firefox (1 - Стабильная, 2 - Бета): " choice
    case $choice in
        1)
            repo="ppa:mozillateam/ppa"
            break
            ;;
        2)
            repo="ppa:mozillateam/firefox-next"
            break
            ;;
        *)
            echo "Пожалуйста, введите 1 или 2."
            ;;
    esac
done

# Добавляем выбранный репозиторий Mozilla Firefox
sudo add-apt-repository $repo

echo "PPA репозиторий mozillateam успешно добавлен"

# Создаем файл для настройки приоритета
echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
' | sudo tee /etc/apt/preferences.d/mozilla-firefox

# Обновляем информацию о пакетах
sudo apt update

# Устанавливаем Firefox
sudo apt install firefox

echo "Firefox успешно установлен"
