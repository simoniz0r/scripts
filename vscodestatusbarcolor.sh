#!/bin/bash
# Code from https://github.com/Microsoft/vscode/issues/1884#issuecomment-230790242
echo "Input the color you would like to change the status bar in hex format"
read -p "Color#" COLOR
    echo ".monaco-workbench>.part.statusbar{background-color:#$COLOR;}" | sudo tee -a /usr/share/code/resources/app/out/vs/workbench/electron-browser/workbench.main.css
    echo "Status bar color changed to $COLOR!"
    exit 1