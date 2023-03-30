window.addEventListener('DOMContentLoaded', () => {
  const searchInput = document.getElementById('searchInput');
  const searchButton = document.getElementById('searchButton');
  const searchResults = document.getElementById('searchResults');
  let filesList = [];

  function getFileList() {
    const fileListUrl = 'https://api.github.com/repos/titenko/scripts/git/trees/master?recursive=1';

    fetch(fileListUrl)
      .then(response => response.json())
      .then(data => {
        filesList = data.tree
          .filter(file => file.type === 'blob')
          .map(file => file.path);
      })
      .catch(error => console.error(`Error getting file list: ${error}`));
  }

  function downloadFile(url) {
    const fileName = url.substring(url.lastIndexOf("/") + 1);
    const extension = fileName.lastIndexOf(".") === -1 ? "" : fileName.slice(fileName.lastIndexOf(".") + 1);
    fetch(url)
      .then(response => response.blob())
      .then(blob => {
        const link = document.createElement("a");
        link.href = window.URL.createObjectURL(blob);
        link.download = extension ? fileName : fileName + "." + blob.type.split("/")[1];
        link.click();
      });
  }

  function searchFiles() {
    const searchTerm = searchInput.value.toLowerCase();
    const matchingFiles = filesList.filter(file => file.toLowerCase().includes(searchTerm));

    if (matchingFiles.length === 0) {
      searchResults.innerHTML = 'File not found.';
    } else {
      searchResults.innerHTML = '<p>Search results:</p>';
      matchingFiles.forEach(path => {
        const link = document.createElement('a');
        const icon = document.createElement('i');
        icon.className = 'far fa-file';
        icon.style.marginRight = '5px';
        link.href = `https://github.com/titenko/scripts/blob/master/${path}`;
        link.target = '_blank';
        link.textContent = path;
        link.prepend(icon);

        const downloadLink = document.createElement('a');
        const downloadIcon = document.createElement('i');
        downloadIcon.className = 'fas fa-download';
        downloadIcon.style.marginLeft = '5px';
        downloadLink.href = `https://raw.githubusercontent.com/titenko/scripts/master/${path}`;
        downloadLink.download = path.substring(path.lastIndexOf("/") + 1);
        downloadLink.target = '_blank';
        downloadLink.innerHTML = '&nbsp;Download file';
        downloadLink.prepend(downloadIcon);
        downloadLink.addEventListener('click', (event) => {
          event.preventDefault();
          downloadFile(event.target.href);
        });

        const listItem = document.createElement('li');
        listItem.appendChild(link);
        listItem.appendChild(downloadLink);

        searchResults.appendChild(listItem);
      });
    }
  }

  getFileList();

  searchButton.addEventListener('click', () => {
    searchResults.innerHTML = '';
    searchFiles();
  });

  searchInput.addEventListener('keydown', event => {
    if (event.keyCode === 13) {
      event.preventDefault();
      searchButton.click();
    }
  });
});

