const apiUrl = "https://api.github.com/repos/titenko/scripts/contents";

const createFileElement = ({name, download_url}) => {
  const a = document.createElement("a");
  a.href = download_url;
  a.innerText = name;
  return a;
};

const createFolderElement = (name) => {
  const li = document.createElement("li");
  li.innerText = name;
  li.classList.add("folder");
  li.addEventListener("click", async () => {
    let folderList = li.children[0];
    if (!folderList) {
      const childrenElements = await getFilesAndFolders(name);
      folderList = document.createElement("ul");
      folderList.classList.add("folder");
      childrenElements.forEach(child => {
        const childLi = document.createElement("li");
        childLi.appendChild(child);
        folderList.appendChild(childLi);
      });
      li.appendChild(folderList);
    } else {
      folderList.remove();
    }
  });
  return li;
};

const getFilesAndFolders = async (path) => {
  const response = await fetch(`${apiUrl}/${path}`);
  const data = await response.json();
  const files = [];
  const folders = [];
  data.forEach(item => {
    if (item.type === "file") {
      files.push(createFileElement(item));
    } else if (item.type === "dir") {
      folders.push(createFolderElement(item.name));
    }
  });
  return [...folders, ...files];
};

const main = async () => {
  const folderList = document.getElementById("folderList");
  const fileList = document.getElementById("fileList");
  const elements = await getFilesAndFolders("");
  elements.forEach(element => {
    if (element.classList.contains("folder")) {
      folderList.appendChild(element);
    } else {
      fileList.appendChild(element);
    }
  });
};

main().catch(error => console.error(error));
