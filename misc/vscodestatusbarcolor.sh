#!/bin/bash
# A script that uses 'sed' to replace all colors matching '#007acc' with the hex color of the user's choice.
# This will replace all '#007acc', so there may be some other places that get recolored also (such changes to files on the sidebar)
# Make a backup of your 'workbench.main.css' file before using this in case you are not happy with the changes.

echo "Input the color you would like to change the status bar in hex format"
read -p "Color #" -n 6 -r
echo
if [ -z "$REPLY" ]; then
    echo "No color input"
    exit 0
fi
if [ "${REPLY: -1}" = "#" ];then
    echo "Invalid input; 6 digit hex color code; do not include the '#'"
    exit 0
fi
GETDIR="$(readlink -f $(which code))"
DIR="${GETDIR::-9}"
    sudo sed -i -e 's/007acc/'$REPLY'/g' "$DIR"/resources/app/out/vs/workbench/electron-browser/workbench.main.css
    echo "Status bar color changed to #$REPLY!"
    exit 1