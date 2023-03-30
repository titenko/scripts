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

