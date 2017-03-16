#!/bin/sh
 
SCRIPT_NAME="$0"
ARGS="$@"
NEW_FILE="https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/updatetest.sh"
VERSION="1.1"
 
check_upgrade () {
 
  # check if there is a new version of this file
  # here, hypothetically we check if a file exists in the disk.
  # it could be an apt/yum check or whatever...
  [ -f "$NEW_FILE" ] && {
 
    # install a new version of this file or package
    # again, in this example, this is done by just copying the new file
    echo "Found a new version of me, updating myself..."
    cp "$NEW_FILE" "$SCRIPT_NAME"
    rm -f "$NEW_FILE"
 
    # note that at this point this file was overwritten in the disk
    # now run this very own file, in its new version!
    echo "Running the new version..."
    $SCRIPT_NAME $ARGS
 
    # now exit this old instance
    exit 0
  }
 
  echo "I'm VERSION $VERSION, already the latest version."
}
 
main () {
  # main script stuff
  echo "Hello World! I'm the version $VERSION of the script"
}
 
check_upgrade
main