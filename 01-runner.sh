#!/usr/bin/env bash

BASIC_DIR=$(dirname $0)
export DISTRO_NAME=$(source /etc/os-release; echo "${NAME:-${DISTRIB_ID}} ${VERSION_ID:-${DISTRIB_RELEASE}}")

TEMP=`getopt -o h --long help,swapsize:,hostname:,desktop:,tidever:,no-emacs -- "$@"`
eval set -- "$TEMP"

export SETUP_EMACS=true

while true; do
    case "$1" in
        -h|--help)
            shift 1;;
        --swapsize)
            SETUP_SWAPSIZE=$2
            SETUP_SWAPSIZE=$(( 256*SETUP_SWAPSIZE ))
            shift 2;;
        --hostname)
            SETUP_HOSTNAME=$2
            shift 2;;
        --desktop)
            SETUP_DESKTOP=$(echo "$2" | tr '[:upper:]' '[:lower:]')
            shift 2;;
        --tidever)
            SETUP_TIDE_VER=$2
            shift 2;;
        --no-emacs)
            unset SETUP_EMACS
            shift 1;;
        --)
            shift 2; break;;
        *)
            echo "Internal error!"; exit 1;;
    esac
done

export SETUP_SWAPSIZE=${SETUP_SWAPSIZE:-4096}
export SETUP_HOSTNAME=${SETUP_HOSTNAME:-$USER-$(echo $DISTRO_NAME |awk '{ print $1 }')}
export SETUP_DESKTOP=${SETUP_DESKTOP:-"kde"}

case $DISTRO_NAME in
    Debian*|Ubuntu*|Kali*|Deepin*)
        bash $BASIC_DIR/debian-setup.sh
        ;;
    openSUSE*)
        bash $BASIC_DIR/opensuse-setup.sh
        ;;
    *)
       echo Unknown Distro
       exit 1
       ;;
esac

source $BASIC_DIR/common-setup.sh
case $SETUP_DESKTOP in
    kde)
        source $BASIC_DIR/kde-beautify-setup.sh
        ;;
esac