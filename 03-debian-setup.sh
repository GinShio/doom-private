# update source
sudo apt install apt-transport-https ca-certificates

case $DISTRO_NAME in
    Debian*)
        #sudo sed -i.bkp -e 's/'
        ;;
    Ubuntu*)
        sudo sed -i.bkp -e 's@http://.*security.ubuntu.com@https://mirrors.ustc.edu.cn@g' \
            -e 's@http://.*archive.ubuntu.com@https://mirrors.ustc.edu.cn@g' /etc/apt/sources.list
        ;;
esac
sudo -E apt update && sudo apt dist-upgrade -y

# Common environment
sudo -E apt install -y dash fish ripgrep wget curl fd-find bat fzf emacs sshpass git git-lfs git-doc \
    neofetch figlet aspell sqlite3 xrdp proxychains privoxy zstd zip unzip 7zip \
    inkscape imagemagick-6-common graphviz calibre mpv obs-studio telegram-desktop flatpak osdlyrics

# C++ environment
sudo -E dnf install -y build-essential binutils gdb gcc-9 g++-9 g++-multilib \
    clang clangd clang-tools clang-format clang-tidy lldb lld \
    automake cmake extra-cmake-modules ninja-build ccache \
    'libboost-*-dev' libpoco-dev

# Java environment
sudo -E apt install -y openjdk-11-jdk openjdk-17-jdk

# Python3 environment
sudo -E apt install -y python3 python3-venv
sudo pip3 install pyright

# NodeJS environment
sudo -E apt install -y nodejs node-builtins node-util yarnpkg

# Beam environment
sudo -E apt install -y erlang elixir

# Working dependence
sudo -E apt install -y mesa-utils glslang-tools vulkan-tools spirv-tools spirv-cross bison flex re2c
sudo -E apt install -y glslang-dev libvulkan-dev libx11-dev libxcb-dri3-dev libx11-xcb-dev x11proto-dev
    libxcb-dri2-0-dev libxcb-present-dev libxcb-shm0-dev libxrandr-dev libxshmfence-dev libssl-dev libdrm-dev \
    libssl-dev:i386 libx11-dev:i386 libxcb1-dev:i386 libxcb-dri3-dev:i386 linux-libc-dev:i386 \
    libxcb-dri2-0-dev:i386 libxcb-present-dev:i386 libxshmfence-dev:i386 libxrandr-dev:i386
sudo -E apt install -y libudev-dev mesa-common-dev libgl1-mesa-dev libwayland-dev wayland-protocols \
    xserver-xorg-dev libxfixes-dev libxdamage-dev libxcb-glx0-dev x11proto-gl-dev \
    libxrender-dev libxext-dev libxxf86vm-dev libxkbcommon-dev freeglut3-dev libwaffle-dev \
    python3-distutils python3-numpy python3-mako python3-ruamel.yaml
