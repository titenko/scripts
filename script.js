const apiUrl = "https://api.github.com/repos/titenko/scripts/contents";

fetch(apiUrl)
  .then(response => response.json())
  .then(data => {
    // обработка JSON-ответа API GitHub
    const fileList = document.getElementById("fileList"); // получаем элемент для вывода списка файлов
    for (const item of data) {
      const fileName = item.name;
      const fileUrl = item.download_url;
      const fileType = item.type;
      // создаем новый элемент списка файлов на странице
      const li = document.createElement("li");
      const a = document.createElement("a");
      a.href = fileUrl;
      a.innerText = fileName;
      // добавляем обработчик событий для загрузки файла
      a.addEventListener("click", e => {
        e.preventDefault(); // отменяем стандартное поведение ссылки
        fetch(fileUrl)
          .then(response => response.blob())
          .then(blob => {
            const url = URL.createObjectURL(blob);
            const a = document.createElement("a");
            a.href = url;
            a.download = fileName;
            document.body.appendChild(a);
            a.click();
            a.remove();
          })
          .catch(error => console.error(error));
      });
      li.appendChild(a);
      fileList.appendChild(li);
    }
  })
  .catch(error => console.error(error));
