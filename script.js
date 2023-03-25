const BASE_URL = "https://api.github.com/repos/titenko/scripts/contents/";
const fileTable = document.querySelector("#table");
const backButtonCell = document.createElement("td");
const backButtonLink = document.createElement("a");
backButtonLink.textContent = "Назад";
backButtonLink.classList.add("back");
backButtonCell.appendChild(backButtonLink);
let path = "";

function getFileType(fileName) {
  const fileExtension = fileName.split('.').pop().toLowerCase();
  switch (fileExtension) {
    case 'html':
      return 'HTML';
    case 'css':
      return 'CSS';
    case 'js':
      return 'JavaScript';
    case 'json':
      return 'JSON';
    case 'xml':
      return 'XML-документ';
    case 'md':
      return 'Markdown-документ';
    case 'txt':
      return 'Текстовый документ';
    case 'sh':
      return 'Скрипт';    
    default:
      return 'Файл';
  }
}

function createRow(icon, name, size, type, link) {
  const row = document.createElement("tr");

  const iconCell = document.createElement("td");
  const iconImage = document.createElement("img");
  iconImage.src = icon;
  iconImage.width = 20;
  iconCell.appendChild(iconImage);

  row.appendChild(iconCell);

  const nameCell = document.createElement("td");
  nameCell.classList.add("name");
  if (type === "dir" && name !== "..") {
    const linkElement = document.createElement("a");
    linkElement.href = "#";
    linkElement.textContent = name;
    nameCell.appendChild(linkElement);
    linkElement.addEventListener("click", (event) => {
      event.preventDefault();
      path += `/${name}`;
      loadPath(path);
    });
  } else if (type === "file") {
    const linkElement = document.createElement("a"); // Создаем элемент ссылки
    linkElement.href = link; // Устанавливаем атрибут href для ссылки
    linkElement.textContent = name; // Устанавливаем текст ссылки
    nameCell.appendChild(linkElement); // Добавляем ссылку в ячейку с названием файла
  } else if (name === "..") {
    backButtonLink.href = "#";
    backButtonCell.classList.add("back");
    backButtonCell.style.textAlign = "left"; // добавляем свойство
    nameCell.appendChild(backButtonLink);
    backButtonLink.addEventListener("click", (event) => {
      event.preventDefault();
      path = path.slice(0, path.lastIndexOf("/"));
      loadPath(path);
    });
  }
  row.appendChild(nameCell);

  const typeCell = document.createElement("td");
  const fileType = getFileType(name);
  typeCell.textContent = fileType;
  row.appendChild(typeCell);

  const sizeCell = document.createElement("td");
  sizeCell.textContent = size ? `${size} B` : "";
  row.appendChild(sizeCell);

  return row;
}

function renderFiles(files) {
  const tbody = table.querySelector('tbody');
  tbody.innerHTML = "";

  if (!Array.isArray(files)) {
    return;
  }

  const rows = [];
  const folders = [];
  const other = [];

  files.forEach((file) => {
    const { name, path, size, type } = file;
    if (name.startsWith('.')) { // пропустить скрытые файлы
    return;
  }
    const link = `${BASE_URL}${path}`;
    const icon =
      type === "dir"
        ? "https://img.icons8.com/color/48/000000/folder-invoices.png"
        : "https://img.icons8.com/color/48/000000/file.png";
    const row = createRow(icon, name, size, type, link);

    if (type === "dir") {
      folders.push(row);
    } else {
      other.push(row);
    }
  });

  const rowsSorted = [...folders, ...other];

  if (path !== "") {
    const backRow = createRow(
      "https://img.icons8.com/color/48/000000/folder-invoices.png",
      "..",
      "",
      "dir",
      ""
    );
    rowsSorted.unshift(backRow);
  }

   rowsSorted.forEach((row) => {
    tbody.appendChild(row);
  });
}

function loadPath(path) {
  fetch(`${BASE_URL}${path}`)
    .then((response) => {
      return response.json();
    })
    .then((data) => {
      renderFiles(data);
    })
    .catch((error) => {
      console.error("Error:", error);
    });
}

loadPath(path);

table.addEventListener("click", (event) => {
  const target = event.target;
  if (target.tagName === "A" && target.textContent === "Назад") {
    event.preventDefault();
    path = path.slice(0, path.lastIndexOf("/"));
    loadPath(path);
  }
});

