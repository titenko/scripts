#!/bin/sh
echo "Добро пожаловать в You Care System Fedora"
echo "Этот простой скрипт автоматически:"
echo "- подключить репозиторий RPM Fusion"
echo "- обновит список пакетов,"
echo "- скачает и установить обновления (если есть),"
echo "- удалит все старые ядра,"
echo "- удалит устаревшие пакеты и файлы конфигурации,"
echo "- освободить место на диске без участия пользователя."
echo ""
echo "Скрипт запустится через 5 секунд"
echo ""
sleep 5
echo "Подключение репозитория RPM Fusion"
echo ""
sudo dnf install --nogpgcheck https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
echo ""
echo "Репозиторий RPM Fusion - подключен!"
echo ""
sleep 5
echo ""
echo "Удаление старых ядер"
echo ""
sudo dnf remove $(dnf repoquery --installonly --latest-limit=-2 -q) -y
rpm -qa kernel
echo ""
echo "Старые ядра - удалены"
sleep 5
echo ""
echo "Обновление списка пакетов и установка обновлений"
echo ""
sudo dnf update -y && sudo dnf upgrade -y
echo ""
echo "Операция - завершена!"
echo ""
sleep 5
echo ""
echo "Очистка системы"
echo ""
sudo dnf autoremove -y && sudo dnf clean all -y
echo ""
echo "Операция - завершена!"
sleep 5
