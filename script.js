const apiUrl = "https://api.github.com/repos/titenko/scripts/contents";

const createFileElement = ({name, download_url}) => {
  const a = document.createElement("a");
  a.href = download_url;
  a.innerText = name;
  return a;
};

const createFolderElement = (name, childrenElements) => {
  const ul = document.createElement("ul");
  ul.classList.add("folder");
  const li = document.createElement("li");
  li.innerText = name;
  li.appendChild(ul);
  for (const child of childrenElements) {
    const childLi = document.createElement("li");
    childLi.appendChild(child);
    ul.appendChild(childLi);
  }
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
      const children = await getFilesAndFolders(`${path}/${name}`);
      folders.push(createFolderElement(name, children));
    }
  }
  return [...folders, ...files];
};

const main = async () => {
  const fileList = document.getElementById("fileList");
  const elements = await getFilesAndFolders("");
  for (const element of elements) {
    fileList.appendChild(element);
  }
};

main().catch(error => console.error(error));
