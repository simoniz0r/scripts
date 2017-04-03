#!/bin/bash
# A script that uses 'sed' to replace all colors matching '#007acc' with the hex color of the user's choice.
# This will replace all '#007acc', so there may be some other places that get recolored also (such changes to files on the sidebar)
# A backup copy of the 'workbench.main.css' file will be saved in ~/.vscode/workbench.main.css.backup in case you don't like the changes.
# Use '--revert' to restore the original 'workbench.main.css' file.

GETDIR="$(readlink -f $(which code))"
DIR="${GETDIR::-9}"
read -p "Killing running 'VSCode' process; press ENTER to continue" NUL
killall -9 code
if [ "$1" = "--revert" ];then
    sudo cp ~/.vscode/workbench.main.css.backup "$DIR"/resources/app/out/vs/workbench/electron-browser/workbench.main.css
    echo "Original workbench file restored; restarting 'VSCode'..."
    /usr/bin/code
    exit 0
fi
echo "Input the color you would like to change the status bar in hex format"
read -p "Color #" -n 6 -r
echo
if [ -z "$REPLY" ]; then
    echo "No color input"
    exit 0
fi
if [ "${REPLY: -1}" = "#" ];then
    echo "Invalid input; use 6 digit hex color code; do not include the '#'"
    exit 0
fi
if [ ! -d ~/.vscode ];then
    mkdir ~/.vscode
fi
if [ ! -f ~/.vscode/workbench.main.css.backup ];then
    cp "$DIR"/resources/app/out/vs/workbench/electron-browser/workbench.main.css ~/.vscode/workbench.main.css.backup
    echo "Backup workbench.main.css.backup created in '~/.vscode/'; use '--revert' to restore it."
else
    echo "workbench.main.css.backup exists; skipping backup; use '--revert' to restore it."
fi
sudo sed -i -e 's/007acc/'$REPLY'/g' "$DIR"/resources/app/out/vs/workbench/electron-browser/workbench.main.css
echo "Status bar color changed to #$REPLY!"
echo "Trying to change your color a second time without first using '--revert' will have no effect."
echo "Restarting 'VSCode'..."
/usr/bin/code
exit 0