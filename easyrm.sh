#!/bin/bash
# A bash script that attempts to make 'rm' easier to use by moving files to '~/.easyrmtmp' by default.
# Created by simonizor 3/11/2017

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

help () {
    echo "Tool that uses 'mv' and 'rm' to move files to '~/.easyrmtmp' instead of deleting them by default."
    echo "Usage: 'easyrm.sh /path/to/file' or 'easyrm/sh /path/to/directory/'"
    echo "Note: Files and directories must start with either '/' './' or '~/' for the command to function."
    echo "Note: Directories must have the trailing '/' or you will receive an error."
    echo "Arguments:"
    echo "-h : Shows this help output"
    echo "-c : Removes all files and directories from '~/.easyrmtmp'"
    echo "-p : executes the default 'rm' command and will permanently remove files and directories."
    echo "-f : executes the 'rm' command with '-f' to forcefully and permanetly remove files and directories."
    echo "-u : Removes '~/.easyrmtmp' directory and config file."
}

if [ -f ~/.config/easyrm/easyrm.conf ]; then
    ARG=$1
    if [[ "$ARG" == /* ]]; then
        echo "Moving $1 to '~/.easyrmtmp'"
        mv $1 ~/.easyrmtmp/
    elif [[ "$ARG" == ./* ]]; then
        echo "Moving $1 to '~/.easyrmtmp'"
        mv $1 ~/.easyrmtmp/
    elif [[ "$ARG" == ~/* ]]; then
        echo "Moving $1 to '~/.easyrmtmp'"
        mv $1 ~/.easyrmtmp/
    elif [[ "$ARG" == -* ]]; then
        while getopts ":hpcdfu" opt; do
            case "$opt" in
            h|\?|help)
                help
                exit 0
                ;;
            p)
                echo "$2 will be permanently deleted!"
                read -p "Continue? Y/N" -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    if [ "${2: -1}" = "/" ]; then
                        rm -r $2
                    else
                        rm $2
                    fi
                else
                    echo "$2 was not deleted!"
                fi
                ;;
            c)
                echo "All files in '~/.easyrmtmp' will be permanently deleted!"
                read -p "Continue? Y/N" -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm -r ~/.easyrmtmp/*
                    echo "Finished!"
                else
                    echo "'~/.easyrmtmp' was not deleted!"
                fi
                ;;
            u)
                echo "All files in '~/.easyrmtmp' will be permanently deleted and config file will be removed!"
                read -p "Continue? Y/N" -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm -r ~/.config/easyrm/
                    rm -r ~/.easyrmtmp/
                    echo "Finished!"
                else
                    echo "'~/.easyrmtmp' was not deleted and config file remains!"
                fi
                ;;
            f)
                echo "$2 will be permanently deleted by force!"
                read -p "Continue? Y/N" -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    if [ "${2: -1}" = "/" ]; then
                        rm -rf $2
                    else
                        rm -f $2
                    fi
                else
                    echo "$2 was not deleted!"
                fi
            esac
        done
    else
        echo "Invalid arguments passed."
        help
        exit 1
    fi

    shift $((OPTIND-1))

    [ "$1" = "--" ] && shift
else
    mkdir ~/.config/easyrm/
    echo "'~/.easyrmtmp' has been created." > ~/.config/easyrm/easyrm.conf
    echo "Directory '~/.easyrmtmp' does not exist..."
    echo "Creating '~/.easyrmtmp' directory for temporary storage of removed files/directories..."
    mkdir ~/.easyrmtmp
    echo "Please run the command again"
fi

# End of file