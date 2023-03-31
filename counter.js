// Функция для установки cookie
function setCookie(cname, cvalue, exdays) {
  var d = new Date();
  d.setTime(d.getTime() + (exdays*24*60*60*1000));
  var expires = "expires="+ d.toUTCString();
  document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}

// Функция для получения cookie
function getCookie(cname) {
  var name = cname + "=";
  var decodedCookie = decodeURIComponent(document.cookie);
  var ca = decodedCookie.split(';');
  for(var i = 0; i <ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }
  return "";
}

// Получаем IP-адрес пользователя
var userIP = '';
fetch('https://api.ipify.org?format=json')
  .then(response => response.json())
  .then(data => {
    userIP = data.ip;
    var myIP = userIP; // определяем ваш IP-адрес автоматически
    if (userIP !== myIP) {
      // Получаем счетчик посещений из cookie-файла
      var visitsCount = parseInt(getCookie("visitsCount"));

      // Если счетчик не был установлен, устанавливаем его в 0
      if (isNaN(visitsCount)) {
        visitsCount = 0;
      }

      // Увеличиваем счетчик посещений и обновляем cookie-файл
      visitsCount++;
      setCookie("visitsCount", visitsCount, 365);

      // Обновляем значение элемента на странице
      document.getElementById("visits-count").textContent = visitsCount;
    }
  });

