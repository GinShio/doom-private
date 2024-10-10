# update source
### zypper
sudo zypper rr --all
sudo zypper ar -fcg https://mirrors.shanghaitech.edu.cn/opensuse/tumbleweed/repo/oss SHTU:oss
sudo zypper ar -fcg https://mirrors.shanghaitech.edu.cn/opensuse/tumbleweed/repo/non-oss SHTU:non-oss
sudo zypper ar -fcg https://mirrors.tuna.tsinghua.edu.cn/packman/suse/openSUSE_Tumbleweed TUNA:packman
sudo zypper ar -fcg obs://KDE:Extra openSUSE:kDE:Extra
sudo zypper ar -fcg osb://Virtualization openSUSE:Virtualization
sudo zypper ar -fcg https://download.opensuse.org/repositories/devel:/tools:/compiler/openSUSE_Factory openSUSE:compiler
#sudo zypper ar -fcg https://download.opensuse.org/repositories/server:/messaging/openSUSE_Factory openSUSE:messaging
#sudo zypper ar -fcg https://download.opensuse.org/repositories/utilities/openSUSE_Factory openSUSE:Utilities
sudo -E zypper ref
sudo zypper remove -u valkey mariadb mariadb-client akonadi
sudo -E zypper al cmake-gui git-gui vlc vlc-beta akonadictl
sudo -E zypper dup -y --allow-vendor-change

# Common environment
sudo -E zypper in -y -t pattern devel_basis devel_C_C++ devel_vulkan
sudo -E zypper in -y \
    7zip aspell bat bison cifs-utils curl dash dwarves emacs fd figlet fish flatpak{,-spawn} flex fzf git{,-doc,-lfs} \
    graphviz ImageMagick inkscape libxslt-tools moreutils Mozilla{Firefox,Thunderbird} mpv neofetch obs-studio \
    osdlyrics privoxy proxychains-ng qbittorrent re2c ripgrep sqlite3 sshpass steam telegram-desktop tmux unzip wget \
    xmlto zip zstd

# kDE environment
sudo -E zypper in -y \
    fcitx5{,-rime} filelight{,-lang} freerdp-wayland kdeconnect-kde{,-lang} krdc{,-lang} krfb{,-lang} \
    kvantum-manager{,-lang} pam_kwallet6 partitionmanager{,-lang}

# C++ environment
sudo -E zypper in -y \
    binutils-gold gcc{,-32bit} gcc-c++{,-32bit} gcc-info gcovr gdb \
    clang{,-doc,-extract,-tools,-devel} llvm{,-doc,-opt-viewer,-devel} lldb lld \
    ccache cmake conan doxygen imake kf6-extra-cmake-modules lcov meson mold ninja
sudo -E zypper in -y \
    cli11-devel 'libboost_*-devel' libc++{,abi}-devel libcaca-devel libelf-devel{,-32bit} libexpat-devel{,-32bit} \
    libopenssl-devel{,-32bit} libpciaccess-devel libstdc++-devel{,-32bit} libunwind-devel libxml2-devel{,-32bit} \
    libzstd-devel{,-32bit} nanomsg-devel ncurses5-devel{,-32bit} poco-devel readline-devel{,-32bit} spdlog-devel \
    stb-devel tinyobjloader-devel zlib-devel{,-32bit}

# Rust & Zig environment
sudo -E zypper in -y cargo rust rust-bindgen
sudo -E zypper in -y zig zig-libs zls

# Java environment
sudo -E zypper in -y java-{17,21}-openjdk{,-devel}

# Python3 environment
sudo -E zypper in -y python3 python3-doc python3-pipx python3-pylint python3-virtualenv
sudo -E zypper in -y \
    python3-distutils-extra python3-Jinja2 python3-lit python3-lxml python3-lz4 python3-Mako python3-numpy \
    python3-pybind11{,-devel} python3-pyelftools python3-pytest python3-ruamel.yaml python3-setuptools \
    python3-u-msgpack-python

# NodeJS environment
sudo -E zypper in -y nodejs-common yarn

# Beam environment
sudo -E zypper in -y erlang erlang-doc elixir elixir-doc elixir-hex

# Graphics
sudo -E zypper in -y \
    cairo-devel{,-32bit} freeglut-devel{,-32bit} libclc libdmx-devel libdrm-devel{,-32bit} libfontenc-devel{,-32bit} \
    libFS-devel libglfw3-wayland libglvnd-devel{,-32bit} libICE-devel{,-32bit} libLLVMSPIRVLib-devel \
    libSM-devel{,-32bit} libva-devel{,-32bit} libvdpau-devel{,-32bit} SDL2-devel{,-32bit} waffle-devel wine-devel
sudo -E zypper in -y \
    libX11-devel{,-32bit} libXau-devel{,-32bit} libXaw-devel{,-32bit} libxcb-devel{,-32bit} libxcb-dri2-0{,-32bit} \
    libxcb-dri3-0{,-32bit} libXcomposite-devel{,-32bit} libXcursor-devel{,-32bit} libXdamage-devel{,-32bit} \
    libXdmcp-devel{,-32bit} libXext-devel{,-32bit} libXfixes-devel{,-32bit} libXfont2-devel{,-32bit} \
    libXft-devel{,-32bit} libXi-devel{,-32bit} libXinerama-devel{,-32bit} libxkbcommon-devel{,-32bit} \
    libxkbfile-devel{,-32bit} libXmu-devel{,-32bit} libXpm-devel{,-32bit} libXrandr-devel{,-32bit} \
    libXrender-devel{,-32bit} libXres-devel{,-32bit} libxshmfence-devel libXss-devel{,-32bit} libXt-devel{,-32bit} \
    libXtst-devel{,-32bit} libXv-devel{,-32bit} libXvMC-devel{,-32bit} libXxf86dga-devel libXxf86vm-devel{,-32bit} \
    xcb-proto-devel 'xcb-util*-devel' 'xcb-util*-devel-32bit' xorgproto-devel xorg-x11-server-sdk
sudo -E zypper in -y \
    wayland-devel{,-32bit} wayland-protocols-devel waylandpp-devel
sudo -E zypper in -y \
    glslang-devel glm-devel Mesa-demo-egl{,-32bit} Mesa-demo-es{,-32bit} Mesa-demo-x{,-32bit} Mesa-dri{,-32bit,-devel} \
    Mesa-libGL-devel{,-32bit} Mesa-libEGL-devel{,-32bit} Mesa-libRusticlOpenCL Mesa-vulkan-device-select{,-32bit} \
    Mesa-vulkan-overlay{,-32bit} piglit shaderc libslang2{,-32bit} slang-devel slang-slsh spirv-{cross,tools} \
    spirv-tools-devel{,-32bit} vulkan-{tools,devel}{,-32bit}

# Virtualization & Containerization & Cross compilation
sudo -E zypper in -y -t pattern kvm_tools
sudo -E zypper in -y \
    libvirt libvirt-dbus libvirt-doc \
    qemu{,-extra,-doc,-lang} qemu-{arm,ppc,x86} qemu-linux-user qemu-vhost-user-gpu \
    lxd lxc libvirt-daemon-lxc podman podman-docker buildah \
    cross-{aarch64,arm,ppc64,ppc64le,riscv64,s390x}-{binutils,gcc14,linux-glibc-devel}
# riscv64-suse-linux-gcc -march=rv64gc riscv.c
# clang --target=riscv64-suse-linux --sysroot=/usr/riscv64-suse-linux/sys-root -mcpu=generic-rv64 -march=rv64g riscv.c
# QEMU_LD_PREFIX=/usr/riscv64-suse-linux/sys-root c.out
# QEMU_LD_PREFIX=/usr/riscv64-suse-linux/sys-root QEMU_SET_ENV='LD_LIBRARY_PATH=/usr/riscv64-suse-linux/sys-root/lib64:/usr/lib64/gcc/riscv64-suse-linux/14' cc.out

# TeX environment
sudo -E zypper in -y 'texlive-*'

# Emacs
sudo -E zypper in -y libvterm-{tools,devel} libtool

# Font
sudo -E zypper in -y \
    adobe-source{serif4,sans3,codepro}-fonts \
    adobe-sourcehan{serif,sans}-{cn,hk,jp,kr,tw}-fonts \
    wqy-{bitmap,microhei,zenhei}-fonts \
    fontawesome-fonts \
    symbols-only-nerd-fonts



# Fix missing 32bit devel files
sudo cp /usr/lib{64,}/pkgconfig/libudev.pc && sudo sed -i 's~/usr/lib64~/usr/lib~g' /usr/lib/pkgconfig/libudev.pc
sudo ln -sf /usr/lib/libudev.so{.1,}
sudo cp /usr/lib{64,}/pkgconfig/xshmfence.pc && sudo sed -i 's~/usr/lib64~/usr/lib~g' /usr/lib/pkgconfig/xshmfence.pc
sudo ln -sf /usr/lib/libxshmfence.so{.1,}
LLVM_VERSION=$(llvm-config --version |sed -nE 's/([[:digit:]]+\.[[:digit:]]+).*/\1/p')
sudo ln -sf /usr/lib/libLLVM.so.$(LLVM_VERSION) /usr/lib/libLLVM.so
