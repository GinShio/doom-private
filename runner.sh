#!/usr/bin/env bash

BASIC_DIR=$(dirname $0)
export DISTRO_NAME=$(source /etc/os-release; echo "${NAME:-${DISTRIB_ID}} ${VERSION_ID:-${DISTRIB_RELEASE}}")
export DISTRO_ID=$(source /etc/os-release; echo "${ID}")

TEMP=`getopt -o h --long help,swapsize:,hostname:,desktop:,tidever:,working:: -- "$@"`
eval set -- "$TEMP"

while true; do
    case "$1" in
        -h|--help)
            shift 1;;
        --swapsize)
            SETUP_SWAPSIZE=$2
            shift 2;;
        --hostname)
            SETUP_HOSTNAME=$2
            shift 2;;
        --desktop)
            SETUP_DESKTOP=$(echo "$2" | tr '[:upper:]' '[:lower:]')
            shift 2;;
        --working)
            SETUP_WORKING=${2:-"Khronos3D"}
            shift 2;;
        --)
            shift 2; break;;
        *)
            echo "Internal error!"; exit 1;;
    esac
done

export SETUP_SWAPSIZE=${SETUP_SWAPSIZE:-16}
export SETUP_HOSTNAME=${SETUP_HOSTNAME:-$([[ ! -z $SETUP_WORKING ]] && echo "$SETUP_WORKING-")$USER-$(echo $DISTRO_NAME |awk '{ print $1 }')}
export SETUP_DESKTOP=${SETUP_DESKTOP:-"kde"}

case $DISTRO_NAME in
    Debian*)
        bash $BASIC_DIR/debian-setup.sh
        ;;
    Fedora*)
        bash $BASIC_DIR/fedora-setup.sh
        ;;
    openSUSE*)
        bash $BASIC_DIR/opensuse-setup.sh
        ;;
    *)
       echo Unknown Distro
       exit 1
       ;;
esac
bash $BASIC_DIR/common-setup.sh
bash $BASIC_DIR/common-beautify-setup.sh
case $SETUP_DESKTOP in
    kde)
        bash $BASIC_DIR/kde-beautify-setup.sh
        ;;
esac

# default shell
chsh -s /bin/dash
