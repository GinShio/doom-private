#!/usr/bin/env bash

# user group
sudo usermod -aG kvm,libvirt,render,video $(whoami)

# Directories
mkdir -p $HOME/{Desktop,Documents,Downloads,Music,Pictures,Projects,Public,Templates,Videos}
mkdir -p $HOME/.local/{bin,share,lib}
mkdir -p $HOME/.local/share/{fonts,applications}
mkdir -p $HOME/.config/{user-tmpfiles.d,autostart}
cat <<-EOF >$HOME/.config/user-dirs.dirs
XDG_DESKTOP_DIR="$HOME/Desktop"
XDG_DOCUMENTS_DIR="$HOME/Documents"
XDG_DOWNLOAD_DIR="$HOME/Downloads"
XDG_MUSIC_DIR="$HOME/Music"
XDG_PICTURES_DIR="$HOME/Pictures"
XDG_PUBLICSHARE_DIR="$HOME/Public"
XDG_TEMPLATES_DIR="$HOME/Templates"
XDG_VIDEOS_DIR="$HOME/Videos"
EOF

# swap file && runtime dir
sudo dd if=/dev/zero of=/swapfile bs=4MiB count=$(( 256*SETUP_SWAPSIZE )) status=progress
sudo chmod 0600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
cat <<-EOF |sudo tee -a /etc/fstab
/swapfile                                  none       swap  defaults,pri=10  0  0
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
vm.swappiness=30
EOF
cat <<-EOF |sudo tee -a /etc/systemd/logind.conf.d/runtime-dir.conf
####
#
# These files configure various parameters of the systemd login manager,
# systemd‐logind.service(8). See systemd.syntax(7) for a general description of
# the syntax.
#
# See logind.conf(5), logind.conf.d(5) for more information
#
####
# 100% not work: https://github.com/systemd/systemd/blob/a1b2c92d8290c76a29ccd0887a92ac064e1bb5a1/src/login/logind-user.c#L860

[Login]
RuntimeDirectorySize=99%
EOF
sudo sysctl -p

# tmpfiles.d
### user develop directories
cat <<-EOF >$HOME/.config/user-tmpfiles.d/develop.$USER.conf
d   $XDG_RUNTIME_DIR/issues   0700   $USER   $USER   2w
d   $XDG_RUNTIME_DIR/runner/baseline   0700   $USER   $USER   3d
d   $XDG_RUNTIME_DIR/runner/deqp   0700   $USER   $USER   -
d   $XDG_RUNTIME_DIR/runner/piglit   0700   $USER   $USER   -
d   $XDG_RUNTIME_DIR/runner/vkd3d/bin   0700   $USER   $USER   -
EOF
### LSP directories
cat <<-EOF >$HOME/.config/user-tmpfiles.d/lsp.$USER.conf
d   $XDG_RUNTIME_DIR/lsp/amdvlk   0700   $USER   $USER   -
L+  $HOME/Projects/amdvlk/drivers/xgl/.cache   -   -   -   -   $XDG_RUNTIME_DIR/lsp/amdvlk
d   $XDG_RUNTIME_DIR/lsp/clangd   0700   $USER   $USER   4w
L+  $HOME/.config/clangd   -   -   -   -   $XDG_RUNTIME_DIR/lsp/clangd
d   $XDG_RUNTIME_DIR/lsp/mesa   0700   $USER   $USER   -
L+  $HOME/Projects/mesa/.cache   -   -   -   -   $XDG_RUNTIME_DIR/lsp/mesa
EOF
### Enabled
sudo systemctl enable --now systemd-tmpfiles-clean

# Hosts
sudo cp /etc/hosts /etc/hosts.bkp
curl https://gitlab.com/ineo6/hosts/-/raw/master/next-hosts |sed '1,2d' - |sudo tee -a /etc/hosts
if ! [ -z $SETUP_HOSTNAME ]; then
    sudo hostnamectl set-hostname $SETUP_HOSTNAME
fi

# sudo
cat <<-EOF |sudo tee -a /etc/sudoers.d/privacy
Defaults        rootpw
Defaults        lecture = always # always / never / once
EOF

# Grub boot arguments
# amdgpu.gpu_recovery=1 zswap.enabled=1 zswap.compressor=zstd zswap.max_pool_percent=40

# flatpak
#flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak remote-modify flathub --url=https://mirror.sjtu.edu.cn/flathub

# Virtualization & Containerization & Cross compilation
sudo systemctl enable --now libvirtd
sudo virsh net-autostart default
lxc remote add nju-images https://mirror.nju.edu.cn/lxc-images/ --protocol=simplestreams --public
cat <<-EOF |sudo tee -a /etc/containers/registries.conf
[[registry]]
prefix = "docker.io"
location = "docker.io"
EOF
sudo systemctl enable --now podman

# SSH
mkdir -p $HOME/.ssh
cat <<-EOF >$HOME/.ssh/config
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

# bluetooth
sudo mkdir -p /etc/bluetooth
sudo cp /etc/bluetooth/main.conf /etc/bluetooth/main.conf.bkp >/dev/null 2>&1
cat <<-EOF |sudo tee /etc/bluetooth/main.conf
[Policy]
AutoEnable=true
EOF

# screen
cat <<-EOF >$HOME/.screenrc
escape ^Tt
autodetach on
defshell /bin/fish
EOF

# tmux
cat <<-EOF >$HOME/.tmux.conf
unbind C-b
set -g prefix C-t
bind-key C-t send-prefix
set -g default-terminal 'screen-256color'
set -g history-limit 65535
set -g mouse on
set-option -g status off
set-option -g default-shell "/bin/fish"
EOF

# Programming
ccache -M $(df -h |awk '$6=="/"{print $2 * 0.2}')G

# Remote Desktop (not work)
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
# cat <<-EOF |tee $HOME/.xsession
# \$(dbus-launch --sh-syntax)
# exec /usr/bin/startplasma-x11
# EOF
# sudo systemctl enable --now xrdp.service

# Fish
cd $(mktemp -d)
curl -o fisher.fish -SL https://github.com/jorgebucaran/fisher/raw/main/functions/fisher.fish
fish -C 'source fisher.fish' -c "fisher install jorgebucaran/fisher IlanCosman/tide PatrickF1/fzf.fish"
fish -c "tide configure --auto --style=Rainbow --prompt_colors='True color' --show_time='24-hour format' --rainbow_prompt_separators=Angled --powerline_prompt_heads=Sharp --powerline_prompt_tails=Sharp --powerline_prompt_style='Two lines, character and frame' --prompt_connection=Disconnected --powerline_right_prompt_frame=No --prompt_connection_andor_frame_color=Dark --prompt_spacing=Sparse --icons='Many icons' --transient=No"

# PipX
pipx install pyright
pipx install trash-cli

# Others
cd $(mktemp -d)
### VSCode
sudo -E flatpak install flathub \
    com.visualstudio.code
### Hugo
curl -o hugo.tar.gz -sSL https://github.com/gohugoio/hugo/releases/download/v0.125.4/hugo_0.125.4_linux-amd64.tar.gz
tar -C $HOME/.local/bin -zxvf hugo.tar.gz hugo

# Update desktop database
update-desktop-database $HOME/.local/share/applications
