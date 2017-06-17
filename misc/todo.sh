#!/bin/bash
# A simple script that puts todo lists in ~/.todo/
# Written by simonizor http://simonizor.gq/scripts

helpfunc () {
printf "Usage: todo [OPTION] [ITEM]
todo.sh adds items to todo.list or a custom list if specified.

Options:
    todo                        # Lists items in todo.list or specified list
    todo add 'Item'             # Adds Item to todo.list or specified list
    todo edit                   # Opens the default editor to edit todo.list or specified list
    todo delete 'Item'          # Deletes Item from todo.list or specified list

Examples:
    todo all                    # Lists all items in all todo lists
    todo custom                 # Lists all items in custom.list
    todo add 'Item'             # Adds Item to todo.list
    todo add custom 'Item'      # Adds Item to custom.list
    todo edit custom            # Opens the default editor to edit custom.list
    todo delete 'Item'          # Deletes Item from todo.list
    todo delete custom 'Item'   # Deletes Item from custom.list
"
}

todo () {
    case $1 in
        add)
            if [ ! -z "$4" ]; then
                echo "Use single or double quotes when adding items."
                echo "Ex: todo add category 'Item to add'"
                exit 1
            fi
            if [ -z "$3" ]; then
                echo "- $2" >> ~/.todo/todo.list
                echo
                echo "todo.list:"
                cat ~/.todo/todo.list
                echo
            else
                echo "- $3" >> ~/.todo/$2.list
                echo
                echo "$2.list:"
                cat ~/.todo/$2.list
                echo
            fi
            ;;
        edit)
            if [ -z "$2" ]; then
                $EDITOR ~/.todo/todo.list
                cat ~/.todo/todo.list
            else
                $EDITOR ~/.todo/$2.list
                cat ~/.todo/$2.list
            fi
            ;;
        delete|remove)
            if [ ! -z "$4" ]; then
                echo "Use single or double quotes when deleting items."
                echo "Ex: todo delete category 'Item to delete'"
                exit 1
            fi
            if [ -z "$3" ]; then
                TODOITEM="$(grep -a "$2" ~/.todo/todo.list)"
                DELNUM="$(echo "$TODOITEM" | wc -l)"
                if ! grep -q "$2" ~/.todo/todo.list; then
                    echo "$2 not found in todo.list!"
                    exit 1
                fi
                if [[ "$DELNUM" != "1" ]]; then
                    echo "$DELNUM results found; refine your input."
                    echo "$TODOITEM"
                    exit 1
                fi
                sed -i s:"$TODOITEM"::g ~/.todo/todo.list
                sed -i '/^$/d' ~/.todo/todo.list
                TODOLIST="$(cat ~/.todo/todo.list)"
                if [ ! -z "$TODOLIST" ]; then
                    echo
                    echo "todo.list:"
                    cat ~/.todo/todo.list
                    echo
                else
                    rm ~/.todo/todo.list
                    echo "No items in todo.list; yay!"
                fi
            else
                TODOITEM="$(grep -a "$3" ~/.todo/$2.list)"
                DELNUM="$(echo "$TODOITEM" | wc -l)"
                if ! grep -q "$3" ~/.todo/$2.list; then
                    echo "$3 not found in $2.list!"
                    exit 1
                fi
                if [[ "$DELNUM" != "1" ]]; then
                    echo "$DELNUM results found; refine your input."
                    echo "$TODOITEM"
                    exit 1
                fi
                sed -i s:"$TODOITEM"::g ~/.todo/$2.list
                sed -i '/^$/d' ~/.todo/$2.list
                TODOLIST="$(cat ~/.todo/$2.list)"
                if [ ! -z "$TODOLIST" ]; then
                    echo
                    echo "$2.list:"
                    cat ~/.todo/$2.list
                    echo
                else
                    rm ~/.todo/$2.list
                    echo "No items in $2.list; yay!"
                fi
            fi
            ;;
        help*)
            helpfunc
            ;;
        *)
            if [ -z "$1" ]; then
                if [ -f ~/.todo/todo.list ]; then
                    TODOLIST="$(cat ~/.todo/todo.list)"
                    echo
                    echo "todo:"
                    cat ~/.todo/todo.list
                    echo
                else
                    echo "No items in todo.list; yay!"
                fi
            elif [ "$1" = "all" ]; then
                echo
                for file in $(dir ~/.todo); do
                FILENAME=${file:0:-5}
                echo "$FILENAME:"
                cat ~/.todo/$file
                echo
                done
            else
                if [ -f ~/.todo/$1.list ]; then
                    TODOLIST="$(cat ~/.todo/$1.list)"
                    echo
                    echo "$1.list:"
                    cat ~/.todo/$1.list
                    echo
                else
                    echo "No items in $1.list; yay!"
                fi
            fi
    esac
}

todo "$@"