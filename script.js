const apiUrl = "https://api.github.com/repos/titenko/scripts/contents";
const fileList = document.getElementById("file-list");

async function getFileList(url) {
  try {
    const response = await fetch(url);
    const data = await response.json();
    return data;
  } catch (error) {
    console.log(error);
  }
}

function createBackLink(parentFolderUrl) {
  const backLink = document.createElement("li");
  const backLinkIcon = document.createElement("i");
  const backLinkText = document.createTextNode(" Back");
  const backLinkAnchor = document.createElement("a");

  backLinkIcon.classList.add("fas", "fa-arrow-circle-left", "mr-2");
  backLinkAnchor.appendChild(backLinkIcon);
  backLinkAnchor.appendChild(backLinkText);
  backLinkAnchor.href = "#";
  backLinkAnchor.style.textAlign = "left";
  backLinkAnchor.classList.add("back-link");

  backLink.appendChild(backLinkAnchor);

  backLink.addEventListener("click", () => {
    getFileList(apiUrl).then((data) => {
      displayFileList(data);
    });
  });

  return backLink;
}

function createFolderItem(file) {
  const folderItem = document.createElement("li");
  const folderLink = document.createElement("a");
  const folderIcon = document.createElement("i");
  const folderName = document.createTextNode(" " + file.name);
  const folderSize = document.createTextNode("");

  folderIcon.classList.add("far", "fa-folder", "mr-2");
  folderLink.appendChild(folderIcon);
  folderLink.appendChild(folderName);
  folderLink.href = file.download_url;

  folderLink.addEventListener("click", (event) => {
    event.preventDefault();
    getFileList(file.url).then((data) => {
      displayFileList(data);
    });
  });

  folderItem.appendChild(folderLink);
  folderItem.appendChild(folderSize);
  fileList.appendChild(folderItem);
}

function createFileItem(file) {
  const fileItem = document.createElement("li");
  const fileLink = document.createElement("a");
  const fileIcon = document.createElement("i");
  const fileName = document.createTextNode(" " + file.name);
  const fileSize = document.createTextNode(` ${(file.size / 1024).toFixed(2)} KB`);

  fileIcon.classList.add("far", "fa-file", "mr-2");
  fileLink.appendChild(fileIcon);
  fileLink.appendChild(fileName);
  fileLink.href = file.download_url;

  fileLink.addEventListener("click", (event) => {
    event.preventDefault();
    downloadFile(file.download_url);
  });

  fileItem.appendChild(fileLink);
  fileItem.appendChild(fileSize);
  fileList.appendChild(fileItem);
}

function displayFileList(fileData) {
  fileList.innerHTML = "";

  const currentFolderUrl = fileData[0].url;
  const parentFolderUrl = currentFolderUrl.slice(0, currentFolderUrl.lastIndexOf("/"));
  if (parentFolderUrl !== apiUrl) {
    fileList.appendChild(createBackLink(parentFolderUrl));
  }

  fileData
    .filter(file => !file.name.startsWith("."))
    .sort((a, b) => a.type === b.type ? a.name.localeCompare(b.name) : a.type.localeCompare(b.type))
    .forEach((file) => {
      if (file.type === "dir") {
        createFolderItem(file);
      } else {
        createFileItem(file);
      }
    });
}

getFileList(apiUrl).then((data) => {
  displayFileList(data);
});

