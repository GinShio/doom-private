# update source
sudo -E apt install apt-transport-https ca-certificates
source /etc/os-release
cat <<-EOF |tee /etc/apt/sources.list
deb https://mirrors.shanghaitech.edu.cn/debian/ ${VERSION_CODENAME} main contrib non-free non-free-firmware
# deb-src https://mirrors.shanghaitech.edu.cn/debian/ ${VERSION_CODENAME} main contrib non-free non-free-firmware

deb https://mirrors.shanghaitech.edu.cn/debian/ ${VERSION_CODENAME}-updates main contrib non-free non-free-firmware
# deb-src https://mirrors.shanghaitech.edu.cn/debian/ ${VERSION_CODENAME}-updates main contrib non-free non-free-firmware

deb https://mirrors.shanghaitech.edu.cn/debian/ ${VERSION_CODENAME}-backports main contrib non-free non-free-firmware
# deb-src https://mirrors.shanghaitech.edu.cn/debian/ ${VERSION_CODENAME}-backports main contrib non-free non-free-firmware

deb https://mirrors.shanghaitech.edu.cn/debian-security ${VERSION_CODENAME}-security main contrib non-free non-free-firmware
# deb-src https://mirrors.shanghaitech.edu.cn/debian-security ${VERSION_CODENAME}-security main contrib non-free non-free-firmware
EOF
sudo dpkg --add-architecture i386 && sudo -E apt update && sudo -E apt dist-upgrade -y
sudo apt purge akonadi-server mariadb-common mariadb-server mariadb-client redis
sudo apt-mark hold akonadiconsole

# Common environment
sudo -E apt install -y \
    7zip aspell bat bison cifs-utils curl dash dwarves emacs fd-find figlet firefox-esr fish flatpak flex fzf \
    git{,-doc,-lfs} graphviz imagemagick-6-common inkscape moreutils mpv neofetch obs-studio osdlyrics privoxy \
    proxychains4 qbittorrent re2c ripgrep sqlite3 sshpass steam-{installer,libs} telegram-desktop thunderbird tmux \
    unzip wget xmlto xsltproc zip zstd

# kDE environment
sudo -E apt install -y \
    fcitx5{,-rime} filelight freerdp3-wayland kdeconnect krdc krfb partitionmanager

# C++ environment
sudo -E apt install -y \
    binutils build-essential gcc g++ g++-multilib gcovr gdb \
    clang{,d,-format,-tidy,-tools} libclang-dev llvm{,-dev} lldb lld \
    ccache cmake doxygen extra-cmake-modules lcov meson mold ninja-build
sudo -E apt install -y \
    libboost1.81-all-dev libc++{,abi}-dev libcaca-dev{,:i386} libcli11-dev libelf-dev{,:i386} libexpat1-dev{,:i386} \
    libnanomsg-dev libncurses5-dev libpciaccess-dev{,:i386} libpoco-dev libreadline-dev{,:i386} libssl-dev{,:i386} \
    libspdlog-dev{,:i386} libstb-dev libtinyobjloader-dev libudev-dev{,:i386} libunwind-14-dev{,:i386} \
    libxml2-dev{,:i386} libzip-dev{,:i386} libzstd-dev{,:i386}

# Rust environment
sudo -E apt install -y cargo rust-all librust-bindgen-dev

# Java environment
sudo -E apt install -y openjdk-17-{jdk,jre}

# Python3 environment
sudo -E apt install -y python3 python3-virtualenv python3-doc pylint pipx
sudo -E apt install -y \
    python3-distutils-extra python3-jinja2 python3-lxml python3-lz4 python3-mako python3-numpy python3-pybind11 \
    python3-pyelftools python3-pytest python3-ruamel.yaml python3-setuptools python3-u-msgpack
pipx install conan

# NodeJS environment
sudo -E apt install -y nodejs node-builtins node-util yarnpkg

# Beam environment
sudo -E apt install -y erlang elixir

# Graphics
sudo -E apt install -y \
    freeglut3-dev{,:i386} glslang-{dev,tools} libcairo2-dev{,:i386} libdmx-dev libdrm-dev{,:i386} \
    libfontenc-dev{,:i386} libglfw3-{dev,wayland} libglvnd-dev{,:i386} \
    libllvmspirvlib-$(llvm-config --version |awk -F. '{print $1}')-dev libsdl2-dev{,:i386} libva-dev{,:i386} \
    libvdpau-dev{,:i386} libwaffle-dev{,:i386} xutils-dev
sudo -E apt install -y \
    libx11-dev{,:i386} libx11-xcb-dev{,:i386} libxcb-dri2-0-dev{,:i386} libxcb-dri3-dev{,:i386} \
    libxcb-glx0-dev{,:i386} libxcb-present-dev{,:i386} libxcb-shm0-dev{,:i386} libxcomposite-dev{,:i386} \
    libxcursor-dev{,:i386} libxdamage-dev{,:i386} libxext-dev{,:i386} libxfixes-dev{,:i386} libxi-dev{,:i386} \
    libxinerama-dev{,:i386} libxkbcommon-dev{,:i386}   libxrandr-dev{,:i386} libxrender-dev{,:i386} \
    libxshmfence-dev{,:i386} libxxf86vm-dev{,:i386} x11proto-dev x11proto-gl-dev xorg-dev xserver-xorg-dev
sudo -E apt install -y \
    libwayland-dev{,:i386} libwayland-egl-backend-dev waylandpp-dev wayland-protocols
sudo -E apt install -y \
    libegl1-mesa-dev{,:i386} libgl1-mesa-dev{,:i386} libglm-dev libslang2-dev{,:i386} libvulkan-dev \
    mesa-common-dev{,:i386} mesa-utils piglit slsh spirv-{cross,tools} vulkan-tools vulkan-validationlayers-dev

# Virtualization & Containerization & Cross compilation
sudo -E api install -y \
    virt-manager libvirt-{clients,daemon,dbus,doc} libvirt-daemon-system \
    qemu-{kvm,system,user,utils} libvirt-clients-qemu libvirt-daemon-driver-qemu \
    qemu-efi{,-aarch64,-arm} qemu-system-{,arm,common,data,ppc,x86} \
    lxd lxc libvirt-daemon-driver-lxc podman podman-docker buildah \
    cross-gcc-dev crossbuild-essential-{arm64,armhf,ppc64el,s390x}

# Font
sudo -E apt install -y fonts-wqy-{microhei,zenhei}
cd $(mktemp -d)
curl -o NerdSymbol.tar.xz -sSL https://github.com/ryanoasis/nerd-fonts/releases/latest/NerdFontsSymbolsOnly.tar.xz
mkdir -p $HOME/.local/share/fonts/Symbols-Nerd && tar -xzf NerdSymbol.tar.xz -C $_
