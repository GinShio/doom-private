#!/usr/bin/env bash

BASIC_DIR=$(dirname $0)
export DISTRO_NAME=$(source /etc/os-release; echo "${NAME:-${DISTRIB_ID}} ${VERSION_ID:-${DISTRIB_RELEASE}}")
export DISTRO_ID=$(source /etc/os-release; echo "${ID}")

TEMP=`getopt -o h --long help,swapsize:,hostname:,tidever:,working:: -- "$@"`
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

set -o allexport
source $BASIC_DIR/.setup-info
set +o allexport
echo ${USERNAME:?Missing User Name.} >/dev/null
echo ${USEREMAIL:?Missing User email.} >/dev/null
echo ${ROOT_PASSPHRASE:?Missing local host root passphrase.} >/dev/null
if [[ ! -z $SETUP_WORKING ]]
then
    echo ${WORK_ORGNAIZATION:?Missing work orgnaization.} >/dev/null
    export WORK_ORGNAIZATION=$WORK_ORGNAIZATION-pub
else export WORK_ORGNAIZATION=personal
fi


sudo -Sv <<<"$ROOT_PASSPHRASE"
case $DISTRO_NAME in
    Debian*)
        sudo bash $BASIC_DIR/debian-setup.sh
        ;;
    openSUSE*)
        sudo bash $BASIC_DIR/opensuse-setup.sh
        ;;
    *)
       echo Unknown Distro
       exit 1
       ;;
esac
sudo -Sv <<<"$ROOT_PASSPHRASE"
bash $BASIC_DIR/common-setup.sh
bash $BASIC_DIR/beautify-setup.sh
bash $BASIC_DIR/build.sh
