#!/bin/bash

# Функция для проверки наличия sudo прав
check_sudo() {
    if [ "$(id -u)" != "0" ]; then
        echo "Этот скрипт требует прав sudo."
        if sudo -n true 2>/dev/null; then
            echo "Sudo права получены. Перезапуск скрипта с sudo..."
            exec sudo "$0" "$@"
        else
            echo "Пожалуйста, введите пароль sudo."
            exec sudo "$0" "$@"
        fi
        exit 1
    fi
}

# Проверка sudo прав перед выполнением основного скрипта
check_sudo

set -e  # Прекращает выполнение скрипта при любой ошибке

# Функция для вывода сообщений с отметкой времени
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Функция для проверки наличия утилиты
check_command() {
    if ! command -v "$1" &> /dev/null; then
        log "Ошибка: $1 не установлен. Установите его с помощью 'apt-get install $1'."
        exit 1
    fi
}

# Проверка наличия необходимых утилит
check_command apt-get
check_command dpkg
check_command flatpak
check_command dconf

# Получаем имя текущего пользователя (не root)
SUDO_USER=${SUDO_USER:-$(who -m | awk '{print $1}')}

log "Скрипт полного сброса Linux Mint к заводским настройкам"
log "ВНИМАНИЕ: Этот скрипт удалит все пользовательские данные и настройки!"
read -p "Продолжить? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log "Отменено."
    exit 1
fi

# Опции очистки
read -p "Удалить сторонние программы? (y/n) " -n 1 -r; echo
remove_programs=$REPLY
read -p "Удалить пользовательские Flatpak приложения? (y/n) " -n 1 -r; echo
remove_flatpaks=$REPLY
read -p "Очистить домашний каталог? (y/n) " -n 1 -r; echo
clean_home=$REPLY
read -p "Сбросить настройки dconf? (y/n) " -n 1 -r; echo
reset_dconf=$REPLY
read -p "Сбросить настройки сети? (y/n) " -n 1 -r; echo
reset_network=$REPLY
read -p "Очистить журналы системы? (y/n) " -n 1 -r; echo
clear_logs=$REPLY
read -p "Сбросить настройки GRUB? (y/n) " -n 1 -r; echo
reset_grub=$REPLY

# 1. Обновление списка пакетов
log "Обновление списка пакетов..."
apt-get update

# 2. Удаление сторонних программ (кроме системных)
if [[ $remove_programs =~ ^[Yy]$ ]]; then
    log "Удаление сторонних программ..."
    DEFAULT_PACKAGES=$(comm -12 <(dpkg --get-selections | awk '{print $1}' | sort) <(cat /usr/share/linuxmint/mintinstall/default.list | sort))
    INSTALLED_PACKAGES=$(dpkg --get-selections | awk '{print $1}')
    for pkg in $INSTALLED_PACKAGES; do
        if ! echo "$DEFAULT_PACKAGES" | grep -q "$pkg"; then
            apt-get purge --auto-remove -y "$pkg"
        fi
    done
fi

# 3. Удаление вручную установленных Flatpak программ
if [[ $remove_flatpaks =~ ^[Yy]$ ]]; then
    log "Удаление вручную установленных Flatpak программ..."
    flatpak list --app --columns=application > /tmp/current_flatpak_list.txt
    while read -r flatpak; do
        if ! grep -q "$flatpak" /usr/share/flatpak_default.list; then
            log "Удаление $flatpak..."
            flatpak uninstall -y "$flatpak"
        fi
    done < /tmp/current_flatpak_list.txt
    rm /tmp/current_flatpak_list.txt
fi

# 4. Исправление проблем с зависимостями и пакетами
log "Исправление проблем с зависимостями..."
apt-get -f install -y

# 5. Очистка домашнего каталога, сохраняя важные системные файлы
if [[ $clean_home =~ ^[Yy]$ ]]; then
    log "Очистка домашнего каталога пользователя..."
    important_hidden_files=(".bashrc" ".profile" ".config" ".local" ".Xauthority" ".bash_logout")
    find /home/$SUDO_USER -mindepth 1 -maxdepth 1 \( -type d -o -type f \) | while read -r item; do
        basename_item=$(basename "$item")
        if [[ ! " ${important_hidden_files[@]} " =~ " ${basename_item} " ]] && [[ "$basename_item" != "." ]] && [[ "$basename_item" != ".." ]]; then
            rm -rf "$item"
        fi
    done

    # Пересоздание стандартных папок
    log "Пересоздание стандартных папок в домашнем каталоге..."
    default_dirs=("Desktop" "Documents" "Downloads" "Music" "Pictures" "Public" "Templates" "Videos")
    for dir in "${default_dirs[@]}"; do
        mkdir -p "/home/$SUDO_USER/$dir"
        chown $SUDO_USER:$SUDO_USER "/home/$SUDO_USER/$dir"
    done

    # Восстановление стандартных значков для папок
    if command -v xdg-user-dirs-update &> /dev/null; then
        log "Восстановление стандартных значков для папок..."
        sudo -u $SUDO_USER xdg-user-dirs-update
    fi
fi

# 6. Очистка системных каталогов после удаления программ
log "Очистка системных каталогов после удаления программ..."
system_dirs=("/usr/share" "/usr/lib" "/var/lib" "/etc")
for dir in "${system_dirs[@]}"; do
    log "Проверка и очистка $dir..."
    find "$dir" -type d -empty -delete 2>/dev/null
done

# 7. Поиск и удаление лишних зависимостей
log "Поиск и удаление лишних зависимостей..."
apt-get autoremove --purge -y
apt-get install deborphan -y
deborphan | xargs apt-get -y remove --purge
dpkg -l | awk '/^rc/ {print $2}' | xargs dpkg --purge

# 8. Восстановление конфигурационных файлов к заводским настройкам
log "Восстановление конфигурационных файлов..."
apt-get install --reinstall --purge $(dpkg --get-selections | grep -v deinstall | awk '{print $1}') -y

# 9. Очистка системы от ненужных пакетов и файлов
log "Очистка системы от ненужных пакетов и файлов..."
apt-get autoremove -y
apt-get autoclean -y

# 10. Сброс настроек dconf
if [[ $reset_dconf =~ ^[Yy]$ ]]; then
    log "Сброс настроек dconf..."
    sudo -u $SUDO_USER dconf reset -f /
fi

# 11. Сброс настроек сети
if [[ $reset_network =~ ^[Yy]$ ]]; then
    log "Сброс настроек сети..."
    rm -rf /etc/NetworkManager/system-connections/*
    systemctl restart NetworkManager
fi

# 12. Очистка журналов системы
if [[ $clear_logs =~ ^[Yy]$ ]]; then
    log "Очистка журналов системы..."
    journalctl --vacuum-time=1s
    find /var/log -type f -delete
    for log in /var/log/syslog /var/log/wtmp /var/log/btmp; do
        [ -f "$log" ] && cat /dev/null > "$log"
    done
fi

# 13. Сброс настроек GRUB
if [[ $reset_grub =~ ^[Yy]$ ]]; then
    log "Сброс настроек GRUB..."
    if [ -f /etc/default/grub.bak ]; then
        mv /etc/default/grub.bak /etc/default/grub
    else
        apt-get install --reinstall grub2-common -y
    fi
    update-grub
fi

# 14. Очистка кэша и временных файлов
log "Очистка кэша и временных файлов..."
apt-get clean
rm -rf /tmp/*
rm -rf /var/tmp/*

# 15. Сброс пароля пользователя на стандартный (опционально)
read -p "Сбросить пароль пользователя на стандартный? (y/n) " -n 1 -r; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log "Сброс пароля пользователя..."
    echo "$SUDO_USER:mint" | chpasswd
fi

# 16. Перезагрузка системы
log "Все действия завершены. Система будет перезагружена через 10 секунд."
log "Нажмите Ctrl+C, чтобы отменить перезагрузку."
sleep 10
reboot
