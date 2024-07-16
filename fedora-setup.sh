# Common environment
sudo -E dnf install -y bat curl dash emacs fd-find fish fzf git git-lfs ripgrep sshpass wget \
    p7zip aspell bison figlet flex neofetch privoxy proxychains-ng re2c sqlite3 unzip zip zstd \
    graphviz ImageMagick inkscape mpv obs-studio firefox thunderbird steam flatpak flatpak-spawn \
    bridge-utils

# C++ environment
sudo -E dnf install -y binutils binutils-gold gdb gcc gcc-c++ \
    clang clang-libs clang-tools-extra lldb lld \
    automake cmake extra-cmake-modules meson ninja-build ccache conan \
    'boost-*-devel' poco-devel

# Rust environment
sudo -E dnf install -y cargo rust

# Java environment
sudo -E dnf install -y java-17-openjdk java-17-openjdk-devel \
    java-21-openjdk java-21-openjdk-devel

# Python3 environment
sudo -E dnf install -y python3 python3-virtualenv python3-pylint pipx
pipx install pyright

# NodeJS environment
sudo -E dnf install -y nodejs-common yarnpkg

# Beam environment
sudo -E dnf install -y erlang erlang-doc elixir elixir-doc

# Working dependence
sudo -E dnf install -y spirv-tools libshaderc vulkan-tools glslang-devel mesa-libGL-devel
sudo -E dnf install -y freeglut-devel libdrm-devel elfutils-devel openssl-devel ncurses-devel waffle-devel
sudo -E dnf install -y nanomsg-devel SDL2-devel
sudo -E dnf install -y xorg-x11-server-devel libX11-devel libxcb-devel \
    libXcomposite-devel libXdamage-devel libXext-devel libXfixes-devel libXfont-devel \
    libXfont2-devel libxkbcommon-devel libXrandr-devel libxshmfence-devel libXxf86vm-devel
sudo -E dnf install -y wayland-devel wayland-protocols-devel waylandpp-devel
sudo -E dnf install -y python3-pyelftools python3-ruamel.yaml python3-u-msgpack-python \
    python3-distutils-extra python3-numpy python3-mako python3-jinja2

# Mesa
sudo -E dnf install -y clang-devel llvm-devel spirv-tools-devel libclc spirv-llvm-translator-devel cbindgen

# TeX environment
sudo -E dnf install -y 'texlive-*'

# Emacs
sudo -E dnf install -y libvterm-{tools,devel} libtool

# Font
sudo -E dnf install -y \
    adobe-source-{serif,sans,code}-pro-fonts \
    adobe-source-han-{serif,sans}-{cn,jp,kr,tw}-fonts \
    wqy-{bitmap,microhei,zenhei}-fonts \
    fontawesome-fonts

# Beautify
sudo dnf install -y kvantum python3-docopt python3-numpy python3-pyaudio python3-cffi python3-websockets
