#!/bin/bash

# constants

RED=`tput setaf 1`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
RESET=`tput sgr0`

COLORS=0
LINENUM_FILE="$HOME/.@"

ROOMS_PATH='/tmp/rooms'

if test ! -f "$ROOMS_PATH"; then
    mkdir -p "$ROOMS_PATH"
fi

IFS=$'\n'

# functions

print_room_header() {
    room="$1"
    msg="$2"

    if test $COLORS; then
        echo -n "$BLUE""$room""$RESET"
    else
        echo -n "$room"
    fi

    if test ! -z "$msg"; then
        echo -n " ($msg)"
    fi

    echo
}

error() {
    err="$1"

    if test -z "$err"; then
        err='fatal error'
    fi

    if test $COLORS; then
        echo "$RED""@: $err""$RESET" 1>&2
    else
        echo "@: $err" &1>2
    fi

    rm -f "$tmp_linenum"
    exit 1
}

notice() {
    m="$1"

    if test $COLORS; then
        echo "$BLUE""@: $m""$RESET"
    else
        echo "@: $m" &1>2
    fi
}


# start of code

# check for special flag operations
if test $# -gt 0; then
    case $1 in
    "--rooms")
        cut -f 1 "$LINENUM_FILE"
        exit 0
        ;;

    "--leave")
        room="$2"

        if test -z "$room"; then
            error 'specify room to leave'
            exit 1
        fi

        if ! grep -q "$room	" "$LINENUM_FILE"; then
            error "not currently joined to '$room'"
            exit 1
        fi

        sed -ri "/$room\\t/d" "$LINENUM_FILE"
        notice "left room '$room'"

        exit 0
        ;;

    "--join")
        room="$2"

        if test -z "$room"; then
            error 'specify room to join'
            exit 1
        fi

        if grep -q "$room	" "$LINENUM_FILE"; then
            error "already joined to '$room'"
            exit 1
        fi

        path="$ROOMS_PATH/$room"

        if test ! -f "$path"; then
            error 'no such chat room'
            exit 1
        fi

        num_lines=`cat "$path" | wc -l`

        echo -e "$room\t$num_lines" >> "$LINENUM_FILE"

        notice "joined '$room'"

        exit 0
        ;;
    esac
fi

room="$1"

if test $# -eq 1; then
    # show recent chat history for a room
    room_path="$ROOMS_PATH/$room"

    if test ! -f "$room_path"; then
        error 'no such chat room'
    fi

    print_room_header $room 'recent history'
    tail -n 10 "$room_path"
    exit 0
fi

touch "$LINENUM_FILE"

tmp_linenum="$HOME/.@.temp"
touch "$tmp_linenum"

if test $# -gt 1; then
    # send a message to a room

    shift
    msg="$1"

    shift
    while (( "$#" )); do
        msg="$msg $1"
        shift
    done

    room_path="$ROOMS_PATH/$room"

    if test ! -f "$room_path"; then
        notice "creating room '$room'"
        touch "$room_path"
        chmod a+rw "$room_path"
    fi

    echo "$(date '+%l:%M:%S') $(whoami): $msg" >> "$room_path"

    # update linenums file to follow this chat room
    found=0
    for line in `cat "$LINENUM_FILE"`; do
        file_room=`echo "$line" | cut -f 1`

        if test "$file_room" = "$room"; then
            # chat room is already in this file
            found=1
            break
        fi
    done

    if test $found -eq 0; then
        # need to add this room to the file
        notice "auto-joining '$room'"

        lines_in_room=`cat "$room_path" | wc -l`
        echo -e "$room\t$lines_in_room" >> "$LINENUM_FILE"
    fi
fi

# based on what we just did, we may need to update the linenums
# and show the user new activity in rooms they are joined to

n=0
for line in `cat "$LINENUM_FILE"`; do
    r=`echo "$line" | cut -f 1`
    num=`echo "$line" | cut -f 2`

    if test -z "$r"; then
        break
    fi

    n=$((n + 1))

    path="$ROOMS_PATH/$r"

    if test ! -f "$path"; then
        continue
    fi

    lines_in_room=`cat "$path" | wc -l`

    if test $num -lt $lines_in_room; then
        # activity since last run

        if test ! "$r" = "$room"; then
            # we did not just look at the history for this room
            # or send a message to it

            print_room_header $r 'new activity'
            tail -n "+$((num + 1))" "$path"
        fi
    fi

    echo -e "$r\t$lines_in_room" >> "$tmp_linenum"
done

if test $n -eq 0; then
    notice 'not joined to any chat rooms'
fi

mv "$tmp_linenum" "$LINENUM_FILE"
rm -f "$tmp_linenum"
