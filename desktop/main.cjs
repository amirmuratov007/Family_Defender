const path = require("node:path");
const { app, BrowserWindow, ipcMain, Notification } = require("electron");

app.setAppUserModelId("com.heimdallgroup.familydefender.desktop");

function createWindow() {
  const window = new BrowserWindow({
    width: 1280,
    height: 820,
    minWidth: 1040,
    minHeight: 720,
    title: "Heimdall Family Defender",
    backgroundColor: "#050610",
    autoHideMenuBar: true,
    webPreferences: {
      preload: path.join(__dirname, "preload.cjs"),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });

  window.loadFile(path.join(__dirname, "index.html"));
}

ipcMain.handle("desktop:notify", (_event, payload = {}) => {
  if (!Notification.isSupported()) return false;
  const notification = new Notification({
    title: String(payload.title || "Heimdall"),
    body: String(payload.body || ""),
    silent: false,
  });
  notification.show();
  return true;
});

app.whenReady().then(() => {
  createWindow();
  app.on("activate", () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") app.quit();
});
