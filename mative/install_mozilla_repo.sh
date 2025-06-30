#!/bin/bash
set -e

# === Авто-повтор запуска через sudo, если не root ===
if [[ "$EUID" -ne 0 ]]; then
  echo "⚠️ Этот скрипт требует прав суперпользователя."
  echo "🔐 Запрашиваю пароль sudo..."
  exec sudo "$0" "$@"
fi

# === Проверка наличия wget ===
if ! command -v wget &> /dev/null; then
  echo "📦 Устанавливаем wget..."
  apt-get update
  apt-get install -y wget
fi

# === Создание директории для ключей ===
echo "📁 Создание директории /etc/apt/keyrings (если отсутствует)..."
install -d -m 0755 /etc/apt/keyrings

# === Загрузка ключа Mozilla ===
echo "🔑 Загрузка ключа репозитория Mozilla..."
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- \
  | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
chmod 644 /etc/apt/keyrings/packages.mozilla.org.asc

# === Проверка отпечатка ключа ===
EXPECTED_FINGERPRINT="35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3"
ACTUAL_FINGERPRINT=$(gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc \
  | awk '/pub/{getline; gsub(/^ +| +$/,""); print $0}')

echo "🔍 Проверка отпечатка ключа..."
echo "   Ожидаемый: $EXPECTED_FINGERPRINT"
echo "   Полученный: $ACTUAL_FINGERPRINT"

if [[ "$ACTUAL_FINGERPRINT" == "$EXPECTED_FINGERPRINT" ]]; then
  echo "✅ Отпечаток совпадает."
else
  echo "❌ Ошибка: отпечаток не совпадает!"
  exit 1
fi

# === Добавление системного репозитория Mozilla ===
echo "➕ Добавляем системный репозиторий Mozilla..."
cat > /etc/apt/sources.list.d/mozilla.list <<EOF
# Mozilla APT repository - trusted, system-wide
deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main
EOF
chmod 644 /etc/apt/sources.list.d/mozilla.list

# === Установка приоритета APT ===
echo "⚙️ Настройка приоритета пакетов Mozilla..."
cat > /etc/apt/preferences.d/mozilla <<EOF
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF
chmod 644 /etc/apt/preferences.d/mozilla

# === Обновление индекса пакетов ===
echo "🔄 Обновление списка пакетов..."
apt-get update

# === Интерактив: Установка Firefox ===
echo ""
echo "🔥 Хотите установить Firefox прямо сейчас?"
echo "1) Да, обычный Firefox (стабильная версия)"
echo "2) Да, Firefox ESR"
echo "3) Да, Firefox Beta"
echo "4) Да, Firefox Nightly"
echo "5) Да, Firefox Developer Edition"
echo "6) Нет, не устанавливать"

read -rp "👉 Введите номер (1–6): " choice

case "$choice" in
  1) pkg="firefox" ;;
  2) pkg="firefox-esr" ;;
  3) pkg="firefox-beta" ;;
  4) pkg="firefox-nightly" ;;
  5) pkg="firefox-devedition" ;;
  6) echo "🚫 Установка Firefox пропущена."; exit 0 ;;
  *) echo "❓ Неверный ввод. Установка отменена."; exit 1 ;;
esac

echo "📦 Устанавливаем $pkg..."
apt-get install -y "$pkg"

echo "✅ Установка завершена!"

