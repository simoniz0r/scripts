#!/bin/bash

pad="$(printf '%0.1s' "-"{1..60})"
prepad="$(printf '%-23s')"
padlength1=17
padlength2=7
SORTNUM="5,5"

main () {
    PSCOMMS="$(ps -eo comm --sort=-%cpu --no-headers | tr -d ' ')"
    printf "${prepad}COMMAND            %%CPU   %%MEM   COUNT\n"
    for command in $(echo "$PSCOMMS" | awk '!seen[$1]++' | head -n "$HEADNUM"); do
        if [ "$command" = "WebContent" ]; then
            command="Web"
        fi
        CPU=" $(ps H -eo %cpu,comm --sort=-%cpu --no-headers | grep "$command" | awk '{ SUM += $1} END { print SUM }') "
        MEM=" $(ps -eo %mem,comm --sort=-%cpu --no-headers | grep "$command" | awk '{ SUM += $1} END { print SUM }') "
        COUNT=" $(ps -eo comm --sort=-%cpu --no-headers | grep "$command" | wc -l)"
        printf '%s' "$prepad" "$command "
        printf '%*.*s' 0 $((padlength1 - ${#command} )) "$pad"
        printf '%s' "$CPU"
        printf '%*.*s' 0 $((padlength2 - ${#CPU} )) "$pad"
        printf '%s' "$MEM"
        printf '%*.*s' 0 $((padlength2 - ${#MEM} )) "$pad"
        printf '%s\n' "-$COUNT"
    done | sort -h -k "$SORTNUM" -r
    CPU=""
    MEM=""
    NUM=""
}

case $1 in
    -l*|--l*)
        case $2 in
            1*|2*|3*|4*|5*|6*|7*|8*|9*)
                HEADNUM="$2"
                main
                ;;
            *)
                echo "$2 is not a number!"
                exit 1
                ;;
        esac
        ;;
    -w*|--w*)
        if [ -z "$2" ]; then
            watch -tn 1 "$0" main
        else
            watch -tn 1 "$0" "$2" "$3"
        fi
        ;;
    *)
        HEADNUM="10"
        main
        ;;
esac