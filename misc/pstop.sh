#!/bin/bash

pad="$(printf '%0.1s' " "{1..60})"
prepad="$(printf '%-0s')"
padlength1=19
padlength2=9
HEADNUM="10"
SORT="cat"
SORTNUM="2,2"
SORTPERCENT="%cpu"

main () {
    printf '%s' "$prepad" "COMMAND "
    printf '%*.*s' 0 $((padlength1 - 7 )) "$pad"
    printf '%s' " %CPU "
    printf '%*.*s' 0 $((padlength2 - 6 )) "$pad"
    printf '%s' " %MEM "
    printf '%*.*s' 0 $((padlength2 - 7 )) "$pad"
    printf '%s\n' " COUNT"
    PSCOMMS="$(ps -eo comm --sort=-"$SORTPERCENT" --no-headers | tr -d ' ')"
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
    done | $(echo "$SORT")
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
        -s=*)
            case ${arg:3} in
                cpu)
                    SORTNUM="2,2"
                    SORTPERCENT="%cpu"
                    SORT="sort -n -k "$SORTNUM" -r"
                    ;;
                mem)
                    SORTNUM="3,3"
                    SORTPERCENT="%mem"
                    SORT="sort -n -k "$SORTNUM" -r"
                    ;;
                name)
                    SORTNUM="1,1"
                    SORTPERCENT="comm"
                    SORT="sort -n -k "$SORTNUM""
                    ;;
                count)
                    SORTNUM="4,4"
                    SORT="sort -n -k "$SORTNUM" -r"
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