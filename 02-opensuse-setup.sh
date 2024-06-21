# update source
### zypper
sudo zypper rr --all
sudo zypper ar -fcg https://mirrors.ustc.edu.cn/opensuse/tumbleweed/repo/oss USTC:oss
sudo zypper ar -fcg https://mirrors.ustc.edu.cn/opensuse/tumbleweed/repo/non-oss USTC:non-oss
sudo zypper ar -fcg https://mirrors.ustc.edu.cn/packman/suse/openSUSE_Tumbleweed USTC:packman
sudo zypper ar -fcg obs://KDE:Extra openSUSE:kDE:Extra
sudo zypper ar -fcg osb://Virtualization openSUSE:Virtualization
sudo zypper ar -fcg https://download.opensuse.org/repositories/server:/messaging/openSUSE_Factory openSUSE:messaging
#sudo zypper ar -fcg https://download.opensuse.org/repositories/utilities/openSUSE_Factory openSUSE:Utilities
sudo -E zypper ref
sudo -E zypper al cmake-gui git-gui vlc vlc-beta
sudo -E zypper dup -y --allow-vendor-change

# Common environment
sudo -E zypper in -y -t pattern devel_basis devel_C_C++ devel_vulkan
sudo -E zypper in -y bat curl dash{,-sh} emacs fd fish fzf moreutils git git-doc git-lfs ripgrep sshpass wget \
    7zip aspell bison figlet flex neofetch privoxy proxychains-ng re2c sqlite3 unzip zip zstd \
    graphviz ImageMagick inkscape mpv obs-studio telegram-desktop osdlyrics \
    MozillaFirefox MozillaThunderbird steam flatpak flatpak-spawn

# kDE environment
sudo -E zypper in -y pam_kwallet6 fcitx5 fcitx5-rime krdc krfb kdeconnect-kde \
    partitionmanager partitionmanager-lang freerdp-wayland okular-spectre

# C++ environment
sudo -E zypper in -y gcc gcc-c++ gcc-info gdb binutils-gold \
    clang clang-tools lldb lld \
    cmake kf6-extra-cmake-modules meson ninja ccache conan \
    'libboost_*-devel' poco-devel gcovr lcov \
    libstdc++-devel libstdc++-devel-32bit libc++-devel libc++abi-devel

# Rust environment
sudo -E zypper in -y cargo rust

# Java environment
sudo -E zypper in -y java-17-openjdk java-17-openjdk-devel \
    java-21-openjdk java-21-openjdk-devel

# Python3 environment
sudo -E zypper in -y python3 python3-virtualenv python3-doc python3-pylint python3-pipx
pipx install pyright

# NodeJS environment
sudo -E zypper in -y nodejs-common yarn

# Beam environment
sudo -E zypper in -y erlang erlang-doc elixir elixir-doc elixir-hex

# Working dependence
sudo -E zypper in -y piglit spirv-tools spirv-cross shaderc vulkan-tools glslang-devel Mesa-libGL-devel Mesa-libRusticlOpenCL
sudo -E zypper in -y freeglut-devel libdrm-devel libelf-devel libopenssl-devel ncurses5-devel waffle-devel
sudo -E zypper in -y nanomsg-devel SDL2-devel
sudo -E zypper in -y xcb-proto-devel xorg-x11-server-sdk libX11-devel libxcb-devel \
    libXcomposite-devel libXdamage-devel libXext-devel libXfixes-devel libXfont-devel \
    libXfont2-devel libxkbcommon-devel libXrandr-devel libxshmfence-devel libXxf86vm-devel
sudo -E zypper in -y wayland-devel wayland-protocols-devel waylandpp-devel
sudo -E zypper in -y python3-pyelftools python3-ruamel.yaml python3-u-msgpack-python \
    python3-distutils-extra python3-numpy python3-Mako python3-Jinja2

# Virtualization & Containerization & Cross compilation
sudo -E zypper in -y -t pattern kvm_tools
sudo -E zypper in -y libvirt libvirt-dbus libvirt-doc \
    qemu qemu-extra qemu-linux-user qemu-vhost-user-gpu qemu-doc qemu-lang \
    qemu-x86 qemu-arm qemu-ppc
sudo -E zypper in -y lxd lxc libvirt-daemon-lxc podman podman-docker buildah
sudo -E zypper in -y gcc-32bit gcc-c++-32bit
sudo -E zypper in -y cross-{aarch64,arm,ppc64,ppc64le,riscv64,s390x}-{binutils,gcc14,linux-glibc-devel} cross-arm-none-gcc14
# riscv64-suse-linux-gcc -march=rv64gc riscv.c
# clang --target=riscv64-suse-linux --sysroot=/usr/riscv64-suse-linux/sys-root -mcpu=generic-rv64 -march=rv64g riscv.c
# qemu-riscv64 -L /usr/riscv64-suse-linux/sys-root a.out

# Mesa
sudo -E zypper in -y clang-devel llvm-devel spirv-tools-devel libclc libLLVMSPIRVLib-devel rust-bindgen

# TeX environment
sudo -E zypper in -y 'texlive-*'

# Emacs
sudo -E zypper in -y libvterm-{tools,devel} libtool

# Font
sudo zypper in -y \
    adobe-source{serif4,sans3,codepro}-fonts \
    adobe-sourcehan{serif,sans}-{cn,hk,jp,kr,tw}-fonts \
    wqy-{bitmap,microhei,zenhei}-fonts \
    fontawesome-fonts \
    symbols-only-nerd-fonts

# Beautify
sudo zypper in -y kvantum-manager kvantum-manager-lang libQt6WebSockets6 \
    python3-docopt python3-numpy python3-PyAudio python3-cffi python3-websockets
