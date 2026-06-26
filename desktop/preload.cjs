const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("heimdallDesktop", {
  notify: (payload) => ipcRenderer.invoke("desktop:notify", payload),
});
