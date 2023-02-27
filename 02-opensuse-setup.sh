#!/usr/bin/env bash

# update source
sudo zypper rr --all
sudo zypper ar -fcg https://mirrors.tuna.tsinghua.edu.cn/opensuse/tumbleweed/repo/oss TUNA:oss
sudo zypper ar -fcg https://mirrors.tuna.tsinghua.edu.cn/opensuse/tumbleweed/repo/non-oss TUNA:non-oss
sudo zypper ar -fcg https://mirrors.tuna.tsinghua.edu.cn/packman/suse/openSUSE_Tumbleweed TUNA:packman
sudo zypper ar -fcg obs://KDE:Extra openSUSE:kDE:Extra
sudo zypper ar -fcg obs://home:Ximi1970:Mozilla:Add-ons openSUSE:systray-x
sudo zypper ar -fcg https://download.opensuse.org/repositories/server:/messaging/openSUSE_Factory openSUSE:messaging
sudo zypper ar -fcg https://download.opensuse.org/repositories/utilities/openSUSE_Factory openSUSE:Utilities
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo zypper ar -fcg https://packages.microsoft.com/yumrepos/ms-teams teams
#sudo zypper ar -fcg https://packages.microsoft.com/yumrepos/edge microsoft-edge
sudo zypper ar -fcg https://packages.microsoft.com/yumrepos/vscode vscode
sudo -E zypper ref && sudo zypper dup -y --from TUNA:packman --allow-vendor-change && sudo -E zypper dup -y

# Common environment
sudo -E zypper in -y -t pattern devel_basis devel_C_C++ devel_vulkan
sudo -E zypper in -y dash fish ripgrep wget curl fd bat fzf emacs sshpass git git-lfs git-doc \
    neofetch figlet aspell sqlite3 xrdp proxychains-ng privoxy zstd zip unzip 7zip \
    inkscape ImageMagick graphviz calibre mpv obs-studio telegram-desktop spotify-easyrpm \
    osdlyrics osdlyrics-lang
chsh -s /bin/dash

# kDE environment
if [ $SETUP_DESKTOP = "kde" ]; then
    sudo -E zypper in -y pam_kwallet fcitx5 fcitx5-rime krdc kdeconnect-kde \
        partitionmanager partitionmanager-lang amarok
fi

# C++ environment
sudo -E zypper in -y gcc gcc-c++ gcc-info gdb binutils-gold gcc7 gcc7-c++ \
    clang clang-tools lldb lld \
    cmake extra-cmake-modules ninja ccache \
    'libboost_*-devel' poco-devel

# Java environment
sudo -E zypper in -y java-11-openjdk java-11-openjdk-devel \
    java-17-openjdk java-17-openjdk-devel

# Python3 environment
sudo -E zypper in -y python3 python3-virtualenv python3-doc python3-pylint
sudo pip3 install pyright

# NodeJS environment
sudo -E zypper in -y nodejs-common yarn

# Beam environment
sudo -E zypper in -y erlang erlang-doc elixir elixir-doc

# Working dependence
sudo -E zypper in -y glslang-devel Mesa-libGL-devel wayland-protocols-devel \
    shaderc vulkan-tools spirv-tools spirv-cross bison flex re2c
sudo -E zypper in -y xorg-x11-server-sdk xorg-x11-devel libX11-devel libxcb-devel \
    libXcomposite-devel libXdamage-devel libXext-devel libXfixes-devel \
    libXfont-devel libXfont2-devel libXrandr-devel libxshmfence-devel libXxf86vm-devel \
    libdrm-devel libopenssl-devel wayland-devel waylandpp-devel libelf-devel ncurses5-devel \
    python3-ruamel.yaml python3-u-msgpack-python python3-pyelftools python3-condor python3-future
sudo -E zypper in -y code MozillaThunderbird systray-x steam

# TeX environment
sudo -E zypper in -y 'texlive-*'

# Emacs
sudo -E zypper in -y libvterm-{tools,devel} libtool

# Spotify
spotify-easyrpm --quiet --set-channel stable --create-schedule

# Font
sudo zypper in -y \
    adobe-{sourceserif4,sourcesans3,sourcecodepro}-fonts \
    adobe-sourcehanserif-{cn,hk,jp,kr,tw}-fonts \
    adobe-sourcehansans-{cn,hk,jp,kr,tw}-fonts \
    wqy-{bitmap,microhei,zenhei}-fonts \
    fontawesome-fonts

# Beautify
sudo zypper in -y kvantum-manager kvantum-manager-lang latte-dock \
    applet-window-appmenu applet-window-buttons libQt5WebSockets5 \
    python3-docopt python3-numpy python3-PyAudio python3-cffi python3-websockets