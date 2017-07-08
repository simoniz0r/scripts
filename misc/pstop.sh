#!/bin/bash

pad="$(printf '%0.1s' "-"{1..60})"
prepad="$(printf '%-0s')"
padlength1=19
padlength2=9
HEADNUM="10"
SORTNUM="3,3"
SORTPERCENT="%cpu"

main () {
    PSCOMMS="$(ps -eo comm --sort=-"$SORTPERCENT" --no-headers | tr -d ' ')"
    printf "${prepad}COMMAND              %%CPU     %%MEM    COUNT\n"
    for command in $(echo "$PSCOMMS" | awk '!seen[$1]++' | head -n "$HEADNUM"); do
        if [ "$command" = "WebContent" ]; then
            command="Web"
        fi
        CPU=" $(ps H -eo %cpu,comm --sort=-"$SORTPERCENT" --no-headers | grep "$command" | awk '{ SUM += $1} END { print SUM }') "
        MEM=" $(ps -eo %mem,comm --sort=-"$SORTPERCENT" --no-headers | grep "$command" | awk '{ SUM += $1} END { print SUM }') "
        COUNT=" $(ps -eo comm --sort=-"$SORTPERCENT" --no-headers | grep "$command" | wc -l)"
        printf '%s' "$prepad" "$command "
        printf '%*.*s' 0 $((padlength1 - ${#command} )) "$pad"
        printf '%s' "$CPU"
        printf '%*.*s' 0 $((padlength2 - ${#CPU} )) "$pad"
        printf '%s' "$MEM"
        printf '%*.*s' 0 $((padlength2 - ${#MEM} )) "$pad"
        printf '%s\n' "$COUNT"
    done | sort -n -k "$SORTNUM" -r
}

for arg in "$@"; do
    case $arg in
        -r=*)
            case ${arg:3} in
                1*|2*|3*|4*|5*|6*|7*|8*|9*)
                    HEADNUM="${arg:3}"
                    ;;
                *)
                    echo "${arg:3} is not a valid number choice!"
                    exit 1
                    ;;
            esac
            ;;
        -p=*)
            case ${arg:3} in
                0*|1*|2*|3*|4*|5*|6*|7*|8*|9*)
                    PREPADNUM="%-${arg:3}s"
                    prepad="$(printf "$PREPADNUM")"
                    ;;
                *)
                    echo "${arg:3} is not a valid number choice!"
                    exit 1
                    ;;
            esac
            ;;
        -w)
            PADCHAR=" "
            pad="$(printf '%0.1s' "$PADCHAR"{1..60})"
            ;;
        -c=*)
            PADCHAR="${arg:3}"
            pad="$(printf '%0.1s' "$PADCHAR"{1..60})"
            ;;
        -s=*)
            case ${arg:3} in
                cpu)
                    SORTNUM="3,3"
                    SORTPERCENT="%cpu"
                    ;;
                mem)
                    SORTNUM="5,5"
                    SORTPERCENT="%mem"
                    ;;
                *)
                    echo "${arg:3} is not a valid choice!"
                    exit 1
                    ;;
            esac
            ;;
    esac
done
main