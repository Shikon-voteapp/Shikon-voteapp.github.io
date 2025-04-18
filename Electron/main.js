const { app, BrowserWindow, globalShortcut } = require('electron');

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true
    }
  });

  // 起動時に全画面表示にする
  mainWindow.setFullScreen(true);

  // 指定されたウェブURLを読み込む
  mainWindow.loadURL('https://mamouna-inori.github.io/build/web/');

  // Ctrl+Shift+Escのショートカットを登録
  globalShortcut.register('CommandOrControl+Shift+Delete', () => {
    if (mainWindow.isFullScreen()) {
      mainWindow.setFullScreen(false);
    } else {
      mainWindow.setFullScreen(true);
    }
  });

  mainWindow.on('closed', function() {
    mainWindow = null;
  });
}

app.on('ready', createWindow);

app.on('window-all-closed', function() {
  // ショートカットの登録を解除
  globalShortcut.unregisterAll();
  
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('will-quit', () => {
  // アプリ終了時にもショートカットの登録を解除
  globalShortcut.unregisterAll();
});

app.on('activate', function() {
  if (mainWindow === null) {
    createWindow();
  }
});