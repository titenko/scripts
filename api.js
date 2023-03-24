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
      li.appendChild(a);
      fileList.appendChild(li);
    }
  })
  .catch(error => console.error(error));
