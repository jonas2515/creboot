#!/bin/bash
##
## Custom reboot: Shell script for changing the BootNext EFI variable
##
## Options:
##  -s <bootname>   Set BootNext to the number associated to an alias in the BOOTNUM array
##  -r              Reboot
##  -d              Display all numbers and their aliases
##  -g              Show graphical dialog

declare -A BOOTNUM

BOOTNUM=( [os1]=0003 [os2]=0001 )



usage() { BOOTNAMES=${!BOOTNUM[@]}; echo "Usage: $0 [-s <${BOOTNAMES// /|}>] [-r] [-d] [-g]" 1>&2; exit 1; }

setboot() {
    for i in "${BOOTNUM[@]}"; do
        if [ "$i" == "${BOOTNUM[$1]}" ]; then
            efibootmgr --bootnext ${BOOTNUM[$1]} > /dev/null
            return 0
        fi
    done
    usage
}

showdialog() {
    RES=$(zenity --list \
        --title="Choose boot entry?" \
        --hide-header \
        --column="Entry" \
        $(for i in "${!BOOTNUM[@]}"; do
            echo "$i"
        done))
    if [ -n "$RES" ]; then
        setboot $RES
    fi

    zenity --question --text="Reboot now?"
    if [ "$?" == 0 ]; then
        reboot
    fi
}

while getopts "s:rdg" o; do
    case "${o}" in
        s)
            s=$OPTARG
            setboot ${OPTARG}
            ;;
        r)
            r=1
            reboot
            ;;
        d)
            d=1
            echo -e "Aliases and EFI-Bootnumbers:"
            for i in "${!BOOTNUM[@]}"; do
                echo "  $i: ${BOOTNUM[$i]}"
            done
            echo -e "\nAll EFI-Bootentries:"
            efibootmgr
            ;;
        g)
            g=1
            showdialog
            ;;
        \?)
            usage
            ;;
    esac
done


if [ -z "$s" ] && [ -z "$r" ] && [ -z "$d" ] && [ -z "$g" ]; then
    usage
fi
