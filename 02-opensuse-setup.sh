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
sudo -E zypper ref && sudo zypper dup -y --from TUNA:packman --allow-vendor-change && sudo -E zypper dup -y

# Common environment
sudo -E zypper in -y dash dash-sh fish ripgrep wget curl fd bat fzf sshpass xdg-utils neofetch \
    figlet aspell sqlite3 proxychains-ng privoxy zstd zip unzip 7zip git git-lfs git-doc \
    emacs inkscape ImageMagick graphviz mpv MozillaThunderbird systray-x telegram-desktop \
    obs-studio amarok 'osdlyrics*' steam flatpak v2ray
chsh -s /bin/dash

# kDE environment
if [ $SETUP_DESKTOP = "kde" ]; then
    sudo -E zypper in -y pam_kwallet fcitx5 fcitx5-rime \
        krdc kdeconnect-kde 'partitionmanager*' amarok tlp tlp-rdw
fi

# C++ environment
sudo -E zypper in -y -t pattern devel_C_C++ devel_basis
sudo -E zypper in -y gcc gcc-c++ gcc-info gdb binutils-gold gcc7 gcc7-c++ \
    clang clang-tools lldb lld \
    cmake extra-cmake-modules meson ninja ccache \
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
sudo -E zypper in -y -t pattern devel_vulkan
sudo -E zypper in -y glslang-devel Mesa-libGL-devel wayland-protocols-devel \
    shaderc vulkan-tools spirv-tools spirv-cross bison flex re2c
sudo -E zypper in -y xorg-x11-server-sdk xorg-x11-devel libX11-devel libxcb-devel \
    libXcomposite-devel libXdamage-devel libXext-devel libXfixes-devel \
    libXfont-devel libXfont2-devel libXrandr-devel libxshmfence-devel libXxf86vm-devel \
    libdrm-devel libopenssl-devel wayland-devel waylandpp-devel libelf-devel ncurses5-devel \
    python3-ruamel.yaml python3-u-msgpack-python python3-pyelftools python3-condor python3-future
sudo -E zypper in -y MozillaThunderbird systray-x steam

# TeX environment
sudo -E zypper in -y 'texlive-*' python3-Pygments

# Emacs
sudo -E zypper in -y libvterm-{tools,devel} libtool

# Spotify
#spotify-easyrpm --quiet --set-channel stable --create-schedule

# Font
sudo zypper in -y \
    adobe-{sourceserif4,sourcesans3,sourcecodepro}-fonts \
    adobe-sourcehanserif-{cn,hk,jp,kr,tw}-fonts \
    adobe-sourcehansans-{cn,hk,jp,kr,tw}-fonts \
    wqy-{bitmap,microhei,zenhei}-fonts \
    fontawesome-fonts

# Beautify
sudo zypper in -y 'kvantum-manager*' latte-dock \
    applet-window-appmenu applet-window-buttons libQt5WebSockets5 \
    python3-docopt python3-numpy python3-PyAudio python3-cffi python3-websockets