#!/bin/bash
# A script that uses 'sed' to replace all colors matching '#007acc' with the hex color of the user's choice.
# This will replace all '#007acc', so there may be some other places that get recolored also (such changes to files on the sidebar)
# A backup copy of the 'workbench.main.css' file will be saved in "$DIR"/resources/app/out/vs/workbench/electron-browser/workbench.main.css.backup in case you don't like the changes.
# Use '--revert' to restore the original 'workbench.main.css' file.
# vscodestatusbarcolor.sh - http://www.simonizor.gq/scripts

SCRIPTNAME="$0"
GETDIR="$(readlink -f $(which code))"
DIR="${GETDIR::-9}"

if [ "$1" = "--revert" ];then
    read -p "Killing running 'VSCode' process; press ENTER to continue..." NUL
    killall -9 code
    sudo cp $DIR/resources/app/out/vs/workbench/electron-browser/workbench.main.css.backup $DIR/resources/app/out/vs/workbench/electron-browser/workbench.main.css || { echo "workbench.main.css.backup does not exist; reinstall VSCode to restore your colors :(" ; exit 0 ; }
    sudo rm $DIR/resources/app/out/vs/workbench/electron-browser/vscodestatusbarcolorsh.conf
    echo "Original workbench file restored; restarting 'VSCode'..."
    /usr/bin/code
    exit 0
fi
if [ -f "$DIR/resources/app/out/vs/workbench/electron-browser/vscodestatusbarcolorsh.conf" ];then
    echo "Status bar color already changed; use '--revert' before changing it again!"
    exit 0
fi
read -p "Killing running 'VSCode' process; press ENTER to continue..." NUL
killall -9 code
echo "Input the color you would like to change the status bar in hex format."
read -p "Color #" -n 6 -r
echo
if [ -z "$REPLY" ]; then
    echo "No color input; try again..."
    exec $SCRIPTNAME
fi
if [ "${REPLY: -1}" = "#" ];then
    echo "Invalid input; use 6 digit hex color code; do not include the '#'. Try again..."
    exec $SCRIPTNAME
fi
if [ ! -f "$DIR/resources/app/out/vs/workbench/electron-browser/workbench.main.css.backup" ];then
    sudo cp $DIR/resources/app/out/vs/workbench/electron-browser/workbench.main.css $DIR/resources/app/out/vs/workbench/electron-browser/workbench.main.css.backup
    echo "Backup created in '$DIR/resources/app/out/vs/workbench/electron-browser/workbench.main.css'; use '--revert' to restore it."
else
    echo "workbench.main.css.backup exists; skipping backup. Use '--revert' to restore it."
fi
echo "workbench.main.css status bar color changed to #$REPLY" | sudo tee $DIR/resources/app/out/vs/workbench/electron-browser/vscodestatusbarcolorsh.conf
sudo sed -i -e 's/007acc/'$REPLY'/g' $DIR/resources/app/out/vs/workbench/electron-browser/workbench.main.css
echo "Status bar color changed to #$REPLY!"
echo "Use '--revert' before attempting to change your color again."
echo "Restarting 'VSCode'..."
/usr/bin/code
exit 0