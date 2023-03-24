const apiUrl = "https://api.github.com/repos/titenko/scripts/contents";

const createFileElement = ({name, download_url}) => {
  const a = document.createElement("a");
  a.href = download_url;
  a.innerText = name;
  a.classList.add("file");
  return a;
};

const createFolderElement = (name) => {
  const folderIcon = document.createElement("i");
  folderIcon.classList.add("fas", "fa-folder");
  
  const folderName = document.createElement("span");
  folderName.innerText = name;
  
  const li = document.createElement("li");
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
  });
  
  li.appendChild(folderIcon);
  li.appendChild(folderName);
  
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
