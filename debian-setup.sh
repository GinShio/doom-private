# update source
sudo apt install apt-transport-https ca-certificates
cat <<-EOF |sudo tee /etc/apt/sources.list
deb https://mirrors.shanghaitech.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
# deb-src https://mirrors.shanghaitech.edu.cn/debian/ bookworm main contrib non-free non-free-firmware

deb https://mirrors.shanghaitech.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
# deb-src https://mirrors.shanghaitech.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware

deb https://mirrors.shanghaitech.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
# deb-src https://mirrors.shanghaitech.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware

# deb https://mirrors.shanghaitech.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
# # deb-src https://mirrors.shanghaitech.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware

deb https://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
# deb-src https://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOF
sudo dpkg --add-architecture i386 && sudo -E apt update && sudo apt dist-upgrade -y


# Common environment
sudo -E apt install -y bat curl dash emacs fd-find fish fzf moreutils git git-doc git-lfs ripgrep sshpass wget \
    7zip aspell bison figlet flex neofetch privoxy proxychains re2c sqlite3 unzip zip zstd \
    graphviz imagemagick-6-common inkscape mpv obs-studio telegram-desktop osdlyrics \
    firefox-esr thunderbird steam-installer steam-libs flatpak tmux xsltproc xmlto cifs-utils

# kDE environment
sudo apt install -y fcitx5 fcitx5-rime krdc krfb kdeconnect partitionmanager freerdp3-wayland

# C++ environment
sudo -E apt install -y build-essential binutils gdb gcc g++ g++-multilib gcovr \
    clang clangd clang-tools clang-format clang-tidy llvm lldb lld \
    automake cmake extra-cmake-modules meson ninja-build ccache mold lcov doxygen
sudo -E apt install -y \
    freeglut3-dev{,:i386} libboost1.81-all-dev libc++-dev libc++abi-dev libcaca-dev{,:i386} libcairo2-dev{,:i386} \
    libglfw3-{dev,wayland} libnanomsg-dev libncurses5-dev libpciaccess-dev{,:i386} libpoco-dev libsdl2-dev{,:i386} \
    libssl-dev{,:i386} libstb-dev libtinyobjloader-dev libudev-dev{,:i386} libva-dev{,:i386} libvdpau-dev{,:i386} \
    libxml2-dev{,:i386} libzip-dev{,:i386} libzstd-dev{,:i386} xutils-dev

# Rust environment
sudo -E apt install -y cargo rust-all

# Java environment
sudo -E apt install -y openjdk-17-jdk openjdk-17-jre

# Python3 environment
sudo -E apt install -y python3 python3-virtualenv python3-doc pylint pipx
pipx install pyright
pipx install conan

# NodeJS environment
sudo -E apt install -y nodejs node-builtins node-util yarnpkg

# Beam environment
sudo -E apt install -y erlang elixir

# Working dependence
sudo -E apt install -y python3-pyelftools python3-ruamel.yaml python3-u-msgpack \
    python3-distutils-extra python3-numpy python3-mako python3-jinja2 python3-setuptools python3-lxml

# Graphics
sudo -E apt install -y piglit mesa-utils glslang-{dev,tools} vulkan-tools libvulkan-dev spirv-tools spirv-cross
sudo -E apt install -y libx11-dev{,:i386} libx11-xcb-dev{,:i386} libxcb-dri2-0-dev{,:i386} \
    libxcb-dri3-dev{,:i386} libxcb-glx0-dev{,:i386} libxcb-present-dev{,:i386} libxcb-shm0-dev{,:i386} \
    libxcomposite-dev{,:i386} libxcursor-dev{,:i386} libxdamage-dev{,:i386} libxext-dev{,:i386} libxfixes-dev{,:i386} \
    libxi-dev{,:i386} libxinerama-dev{,:i386} libxkbcommon-dev{,:i386}   libxrandr-dev{,:i386} libxrender-dev{,:i386} \
    libxshmfence-dev{,:i386} libxxf86vm-dev{,:i386} x11proto-dev x11proto-gl-dev xorg-dev xserver-xorg-dev
sudo -E apt install -y libwayland-dev{,:i386} wayland-protocols waylandpp-dev libwayland-egl-backend-dev

# Mesa
sudo -E apt install -y mesa-common-dev{,:i386} libgl1-mesa-dev{,:i386} libegl1-mesa-dev{,:i386}
sudo -E apt install -y vulkan-validationlayers-dev libclang-dev llvm-dev \
    libllvmspirvlib-$(llvm-config --version |awk -F. '{print $1}')-dev librust-bindgen-dev
sudo -E apt install -y libdrm-dev{,:i386} libelf-dev{,:i386} libglvnd-dev{,:i386} libwaffle-dev{,:i386}

# Font
sudo -E apt install -y fonts-wqy-{microhei,zenhei}
cd $(mktemp -d)
curl -o NerdSymbol.tar.xz -sSL https://github.com/ryanoasis/nerd-fonts/releases/latest/NerdFontsSymbolsOnly.tar.xz
mkdir -p $HOME/.local/share/fonts/Symbols-Nerd && tar -xzf NerdSymbol.tar.xz -C $_
