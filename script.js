const apiUrl = "https://api.github.com/repos/titenko/scripts/contents";

const createFileElement = ({name, download_url}) => {
  const a = document.createElement("a");
  a.href = download_url;
  const icon = document.createElement("i");
  icon.classList.add("far", "fa-file");
  a.appendChild(icon);
  const span = document.createElement("span");
  span.innerText = name;
  a.appendChild(span);
  a.classList.add("file");
  return a;
};

const createFolderElement = (name) => {
  const li = document.createElement("li");
  const icon = document.createElement("i");
  icon.classList.add("far", "fa-folder");
  li.appendChild(icon);
  const span = document.createElement("span");
  span.innerText = name;
  li.appendChild(span);
  li.classList.add("folder");
  li.addEventListener("click", async () => {
    const folderList = li.querySelector("ul");
    if (!folderList) {
      const childrenElements = await getFilesAndFolders(`${name}`);
      folderList = document.createElement("ul");
      folderList.classList.add("folder");
      for (const child of childrenElements) {
        const childLi = document.createElement("li");
        childLi.appendChild(child);
        folderList.appendChild(childLi);
      }
      li.appendChild(folderList);
    } else {
      folderList.remove();
    }
    location.reload();
  });
  return li;
};

const getFilesAndFolders = async (path) => {
  const response = await fetch(`${apiUrl}/${path}`);
  const data = await response.json();
  const files = [];
  const folders = [];
  for (const item of data) {
    const name = item.name;
    const download_url = item.download_url;
    if (item.type === "file") {
      files.push(createFileElement({name, download_url}));
    } else if (item.type === "dir") {
      folders.push(createFolderElement(name));
    }
  }
  return [...folders, ...files];
};

const main = async () => {
  const folderList = document.getElementById("folderList");
  const fileList = document.getElementById("fileList");
  const elements = await getFilesAndFolders("");
  for (const element of elements) {
    if (element.classList.contains("folder")) {
      folderList.appendChild(element);
    } else {
      fileList.appendChild(element);
    }
  }
};

main().catch(error => console.error(error));
