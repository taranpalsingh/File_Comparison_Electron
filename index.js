const electron = require('electron');
const url = require('url');
const path = require('path');

const { app, BrowserWindow, Menu } = electron;

let mainWindow;

app.on('ready', ()=>{
    mainWindow = new BrowserWindow({
        webPreferences: {
            nodeIntegration: true
        },
        title: "Compare files and folders"
    })

    // Maximize window
    mainWindow.maximize();

    mainWindow.loadURL(url.format({
        pathname: path.join(__dirname, 'mainWindow.html'),
        protocol: 'File',
        slashes: true
    }))

    mainWindow.on('closed', ()=>{
        app.quit();
    })

    const mainMenu = Menu.buildFromTemplate(mainMenuTemplate);
    // Insert menu
    Menu.setApplicationMenu(mainMenu);
});

const mainMenuTemplate = [
    {
        label: 'File',
        submenu:[
            {
                label: 'Quit',
                accelerator: process.platform === 'darwin' ? 'Command+Q': 'Ctrl+Q',
                click(){
                    app.quit();
                }
            },
            {
                role: 'reload'
            }        
        ]
    }
]


if(process.env.NODE_ENV !== 'production'){
    mainMenuTemplate.push({
        label: 'Developer Tools',
        submenu: [
            {
                label: 'Toggle DevTools',
                accelerator: process.platform == 'darwin' ? 'Command+I': 'Ctrl+I',
                click(item, focusedWindow){
                    focusedWindow.toggleDevTools();
                }
            },
            {
                role: 'reload'
            }
        ]
    })
}
