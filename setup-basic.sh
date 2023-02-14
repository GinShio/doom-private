#!/usr/bin/env bash

# Directories
mkdir -p $HOME/{Desktop,Documents,Downloads,Music,Pictures,Projects,Public,Templates,Videos,.temp}
mkdir -p $HOME/.local/{bin,share,lib}
mkdir -p $HOME/.local/share/{fonts,applications}
cat <<-EOF |tee $HOME/.config/user-dirs.dirs
XDG_DESKTOP_DIR="$HOME/Desktop"
XDG_DOCUMENTS_DIR="$HOME/Documents"
XDG_DOWNLOAD_DIR="$HOME/Downloads"
XDG_MUSIC_DIR="$HOME/Music"
XDG_PICTURES_DIR="$HOME/Pictures"
XDG_PUBLICSHARE_DIR="$HOME/Public"
XDG_TEMPLATES_DIR="$HOME/Templates"
XDG_VIDEOS_DIR="$HOME/Videos"
EOF

# swap file
sudo dd if=/dev/zero of=/swapfile bs=4MiB count=16384 status=progress
sudo chmod 0600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
cat <<-EOF |sudo tee -a /etc/fstab
/swapfile                                  none       swap  defaults,pri=20  0  0
EOF
# sudo sysctl -w vm.swappiness=16
cat <<-EOF |sudo tee -a /etc/sysctl.conf
####
#
# To disable or override a distribution provided file just place a
# file with the same name in /etc/sysctl.d/
#
# See sysctl.conf(5), sysctl.d(5) and sysctl(8) for more information
#
####
vm.swappiness=10
EOF
sudo sysctl -p

# Hosts
sudo cp /etc/hosts /etc/hosts.bkp
curl https://raw.githubusercontent.com/ineo6/hosts/master/hosts |sed '1,4d' - |sudo tee -a /etc/hosts

# sudo
echo "Defaults        lecture = always" |sudo tee -a /etc/sudoers.d/privacy # prompt: always / never / once

# update source
### zypper
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
### flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# KDE wallet
sudo -E zypper in -y pam_kwallet
cat <<-EOF |sudo tee -a /etc/pam.d/sddm
auth     optional       pam_kwallet5.so
session  optional       pam_kwallet5.so auto_start
EOF

# Common environment
sudo -E zypper in -y dash fish ripgrep wget curl fd bat fzf emacs sshpass \
    git git-lfs neofetch figlet fcitx5 fcitx5-rime aspell sqlite3 \
    zstd zip unzip 7zip inkscape ImageMagick graphviz calibre kdeconnect-kde \
    partitionmanager proxychains-ng privoxy git-doc partitionmanager-lang osdlyrics-lang \
    mpv amarok obs-studio telegram-desktop spotify-easyrpm osdlyrics
chsh -s /bin/dash

# C++ environment
sudo -E zypper in -y gcc gcc-c++ gcc-info gdb binutils-gold gcc7 gcc7-c++ \
    clang clang-tools lldb lld \
    cmake extra-cmake-modules ninja ccls ccache \
    libboost_*-devel poco-devel

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
    shaderc vulkan-tools spirv-tools spirv-cross bison flex re2c htcondor
sudo -E zypper in -y xorg-x11-server-sdk xorg-x11-devel libX11-devel libxcb-devel \
    libXcomposite-devel libXdamage-devel libXext-devel libXfixes-devel \
    libXfont-devel libXfont2-devel libXrandr-devel libxshmfence-devel libXxf86vm-devel \
    libdrm-devel libopenssl-devel wayland-devel waylandpp-devel libelf-devel ncurses5-devel \
    python3-ruamel.yaml python3-u-msgpack-python python3-pyelftools python3-condor python3-future
sudo -E zypper in -y teams code MozillaThunderbird systray-x steam

# SSH
mkdir -p $HOME/.ssh
cat <<-EOF |tee $HOME/.ssh/config
# https://docs.github.com/en/authentication/troubleshooting-ssh/using-ssh-over-the-https-port
Host github github.com
    Hostname ssh.github.com
    User git
    Port 443
    PreferredAuthentications publickey
    IdentityFile $HOME/.ssh/amd-pub-git

# https://docs.gitlab.com/ee/user/gitlab_com
Host gitlab gitlab.com
    Hostname altssh.gitlab.com
    User git
    Port 443
    PreferredAuthentications publickey
    IdentityFile $HOME/.ssh/amd-pub-git

# https://garbers.co.za/2014/03/03/connecting-to-bitbucket-on-https-port
Host bitbucket bitbucket.org
    Hostname altssh.bitbucket.org
    User git
    Port 443
    PreferredAuthentications publickey
    IdentityFile $HOME/.ssh/amd-pub-git
EOF
#ssh-keygen -C "ED25519 Comment" -t ed25519     -f "$HOME/.ssh/amd-pub-git" -N ""
#ssh-keygen -C "RSA Comment"     -t rsa -b 4096 -f "$HOME/.ssh/amd-pub-git" -N ""
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bkp >/dev/null 2>&1
cat <<-EOF |sudo tee /etc/ssh/sshd_config
Port 22
Protocol 2

MaxAuthTries 8
MaxSessions 32

RSAAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
EOF
sudo systemctl enable --now sshd.service

# Remote Desktop (don't work)
sudo -E zypper in -y xrdp krdc
# x11vnc -storepasswd $HOME/.vnc/passwd
# cat <<-EOF |sudo tee /etc/systemd/system/x11vnc.service
# [Unit]
# Description=X11vnc server
# Requires=display-manager.service
# After=display-manager.service
#
# [Service]
# Type=forking
# ExecStartPre=/bin/bash -c "/usr/bin/systemctl set-environment SDDMXAUTH=\$(/usr/bin/find /var/run/sddm/ -type f)"
# ExecStart=/bin/bash -c "/usr/bin/x11vnc -display :0 -auth \${SDDMXAUTH} -ncache 10 -forever -loop -shared -bg -rfbauth >
# #ExecStart=/bin/bash -c "/usr/bin/x11vnc -auth /var/run/sddm/* -display :0 -forever -loop -noxdamage -repeat -rfbauth $>
# ExecStop=/usr/bin/killall x11vnc
# Restart=on-failure
# RestartSec=3
#
# [Install]
# WantedBy=graphical.target
# EOF
cat <<-EOF |tee $HOME/.xsession
\$(dbus-launch --sh-syntax)
exec /usr/bin/startplasma-x11
EOF
sudo systemctl enable --now xrdp.service

# Others
cd $(mktemp -d)
### Spotify
spotify-easyrpm --quiet --set-channel stable --create-schedule
### Hugo
curl -o hugo.tar.gz -sSL https://github.com/gohugoio/hugo/releases/download/v0.109.0/hugo_extended_0.109.0_Linux-64bit.tar.gz
tar -C $HOME/.local/bin -zxvf hugo.tar.gz hugo
### Perforce
curl -o p4v.tgz -sSL https://cdist2.perforce.com/perforce/r18.2/bin.linux26x86_64/p4v.tgz
tar -zxvf p4v.tgz -C $HOME/.local/share
cat <<-EOF |tee $HOME/.local/share/applications/p4v.desktop
[Desktop Entry]
Name=Perforce
GenericName=Version Control GUI
Comment=Perforce GUI
Icon=$HOME/.local/share/p4v-2018.2.1687764/lib/P4VResources/icons/p4v.svg
Exec=p4v
Terminal=false
StartupNotify=false
Type=Application
Categories=Development;RevisionControl;
X-KDE-StartupNotify=false
EOF
ln -sf $HOME/.local/share/p4v-2018.2.1687764/bin/p4v $HOME/.local/bin
update-desktop-database $HOME/.local/share/applications
### Tex
sudo -E zypper in -y 'texlive-*'
### Emacs
sudo -E zypper in -y libvterm-{tools,devel} libtool
git clone --depth 1 https://github.com/domtronn/all-the-icons.el.git
cd all-the-icons.el/fonts
mkdir -p $HOME/.local/share/fonts/all-the-icons && cp *.ttf $HOME/.local/share/fonts/all-the-icons
git clone --depth 1 github:doomemacs/doomemacs.git $HOME/.emacs.d
git clone gitlab:GinShio/doom-private.git $HOME/.doom.d
emacs --batch --eval "(progn (require 'org) (setq org-confirm-babel-evaluate nil) (org-babel-tangle-file \"$HOME/.doom.d/config.org\"))"
$HOME/.emacs.d/bin/doom install && $HOME/.emacs.d/bin/doom sync
curl -o twemoji-v2.tar -sSL "https://raw.githubusercontent.com/iqbalansari/emacs-emojify/9e36d0e8c2a9c373a39728f837a507adfbb7b931/twemoji-fixed-v2.tar"
mkdir -p $HOME/.emacs.d/.local/cache/emojis && tar -C $HOME/.emacs.d/.local/cache/emojis -xvf twemoji-v2.tar
