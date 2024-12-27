#!/usr/bin/env fish
# copy this file to ~/.config/fish/config

if status is-interactive
    # Commands to run in interactive sessions can go here
    set --universal fish_greeting

    function setconda
        source $HOME/.local/share/anaconda3/etc/fish/conf.d/conda.fish
    end

    function unproxy
        set -e no_proxy
        set -e http_proxy
        set -e https_proxy
    end

    function zswap_statistics
        # Copy from https://unix.stackexchange.com/questions/406936/get-current-zswap-memory-usage-and-statistics.
        # Authored-by: Вадим Илларионов
        set -l command_string '
MDL=/sys/module/zswap
DBG=/sys/kernel/debug/zswap
PAGE=$(($(cat $DBG/stored_pages)*4096))
POOL=$(cat $DBG/pool_total_size)
EN=$(cat $MDL/parameters/enabled)

Show(){
    printf "========\n$1\n========\n"
    grep -R . $2 2>/dev/null |sed "s|.*/||"
}

Show Settings $MDL
Show Stats    $DBG

printf "\nCompression ratio: "
[ $POOL -gt 0 ] && { echo "scale=3;$PAGE/$POOL" | bc; } || { [ $EN = "Y" ] && echo 0 || echo disabled; }
'
        test $EUID -ne 0 && sudo -- bash -c $command_string || bash -c $command_string
    end

    function copy_graphics_testcase
        argparse deqp piglit tool vkd3d -- $argv
        or return
        set -fx PROJECT_DIR $HOME/Projects
        set -fx RUNNER_DIR $XDG_RUNTIME_DIR/runner

        if set -ql _flag_deqp
            set -lx DEQP_SRCDIR $PROJECT_DIR/deqp
            set -lx DEQP_DSTDIR $RUNNER_DIR/deqp
            rsync $DEQP_SRCDIR/_build/external/vulkancts/modules/vulkan/Release/deqp-vk $DEQP_DSTDIR
            rsync -rR $DEQP_SRCDIR/external/vulkancts/data/./vulkan $DEQP_DSTDIR
            rsync -rR --exclude-from=$DEQP_DSTDIR/vk-exclude.txt $DEQP_SRCDIR/external/vulkancts/mustpass/main/./vk-default $DEQP_DSTDIR/mustpass
            rsync $DEQP_SRCDIR/_build/external/openglcts/modules/Release/glcts $DEQP_DSTDIR
            rsync -rR $DEQP_SRCDIR/_build/external/openglcts/modules/./gles{2,3,31}/{data,shaders} $DEQP_DSTDIR
            rsync -rR $DEQP_SRCDIR/_build/external/openglcts/modules/./gl_cts/data/GTF $DEQP_DSTDIR
            rsync -rR $DEQP_SRCDIR/external/graphicsfuzz/data/./gles3/graphicsfuzz/ $DEQP_DSTDIR
            rsync -rR --exclude='mustpass' $DEQP_SRCDIR/external/openglcts/data/./gl_cts $DEQP_DSTDIR
            rsync -rR --exclude='src' $DEQP_SRCDIR/external/openglcts/data/gl_cts/data/mustpass/./gl/khronos_mustpass{,_single}/main/*.txt $DEQP_DSTDIR/mustpass
            rsync -rR --exclude='src' $DEQP_SRCDIR/external/openglcts/data/gl_cts/data/mustpass/./{egl,gles}/*_mustpass/main/*.txt $DEQP_DSTDIR/mustpass
            rsync -rR $DEQP_SRCDIR/external/openglcts/data/gl_cts/data/mustpass/./waivers $DEQP_DSTDIR/mustpass
            fd --regex '.*\.txt' -- $DEQP_DSTDIR/mustpass/vk-default |sed -e "s~^$DEQP_DSTDIR/mustpass/~~" >$DEQP_DSTDIR/mustpass/vk-default.txt
        end

        if set -ql _flag_piglit
            set -lx PIGLIT_SRCDIR $PROJECT_DIR/piglit
            set -lx PIGLIT_DSTDIR $RUNNER_DIR/piglit
            rsync -rR $PIGLIT_SRCDIR/_build/./bin $PIGLIT_DSTDIR
            rsync -rR $PIGLIT_SRCDIR/./{framework,templates} $PIGLIT_DSTDIR
            rsync -rR $PIGLIT_SRCDIR/_build/./tests/*.xml.gz $PIGLIT_DSTDIR
            rsync -mrR -f'- *.[chao]' -f'- *.[ch]pp' -f'- *[Cc][Mm]ake*' $PIGLIT_SRCDIR/./tests $PIGLIT_DSTDIR
            rsync -rR $PIGLIT_SRCDIR/./generated_tests/**/*.inc $PIGLIT_DSTDIR
            rsync -mrR -f'- *.[chao]' -f'- *.[ch]pp' -f'- *[Cc][Mm]ake*' $PIGLIT_SRCDIR/_build/./generated_tests $PIGLIT_DSTDIR
        end

        if set -ql _flag_tool
            rsync $PROJECT_DIR/runner/_build/release/{deqp,piglit}-runner $RUNNER_DIR
        end

        if set -ql _flag_vkd3d
            set -lx VKD3D_SRCDIR $PROJECT_DIR/vkd3d
            set -lx VKD3D_DSTDIR $RUNNER_DIR/vkd3d
            rsync -f'- */' -f'- *.a' $VKD3D_SRCDIR/_build/_rel/tests/* $VKD3D_DSTDIR/bin
            rsync -rR $VKD3D_SRCDIR/tests/./{d3d12_tests.h,test-runner.sh} $VKD3D_DSTDIR/tests
            rsync -rR $VKD3D_SRCDIR/_build/_rel/./libs/**/*.so $VKD3D_DSTDIR
        end
    end

    function __ginshio_command_abbreviation
        #alias cat "lolcat"
        alias clear "clear && echo -en \"\e[3J\""
        alias ping "ping -c 8"
        #alias oneko=" oneko -fg brown -bg white -speed 16 -idle 100"
        #alias uuid=" cat /proc/sys/kernel/random/uuid"
        #abbr -a pc "proxychains4"
        #abbr -a spc "sudo proxychains4"
        if type -q fdfind; and not type -q fd
            alias fd "fdfind"
        end
        if type -q batcat; and not type -q bat
            alias bat "batcat"
        end
    end

    # package management
    #   - repository management
    #     - ar         addrepo                  添加源
    #     - lr         repos                    列出源
    #     - ref        refresh                  刷新源
    #     - rr         removerepo               移除源
    #     - mr         modifyrepo               调整源
    #     - nr         renamerepo               重命名源
    #   - package management
    #     - arm        autoremove               自动移除
    #     - in         install                  安装
    #     - rm         remove                   移除
    #     - si         source-install           源码包安装
    #   - update management
    #     - dup        dist-upgrade             发行版升级
    #     - lu         list-updates             列出需升级的包
    #     - up         update                   更新
    #   - querying
    #     - if         info                     获取包信息
    #     - se         search                   查询
    #     - wp         what-provides            提供的包
    #   - locking
    #     - al         addlock                  锁定
    #     - ll         locks                    列出锁定
    #     - rl         removelock               移除锁定
    #     - cl         cleanlocks               ???
    #   - utilities
    #     - cln        clean                    清除本地缓存
    #     - inr        install-new-recommends   安装新的推荐
    #     - ps         check-process            检测最近修改但仍在运行的程序
    #     - ve         verify                   验证依赖

    function __ginshio_zypp_package_management
        # repository management
        abbr -a Par  "sudo zypper addrepo -fcg"
        abbr -a Plr  "zypper repos -Np"
        abbr -a Pref "sudo -E zypper refresh"
        abbr -a Prr  "sudo zypper removerepo"
        abbr -a Pmr  "sudo zypper modifyrepo"
        abbr -a Pnr  "sudo zypper renamerepo"
        # package management
        abbr -a Parm ""
        abbr -a Pin  "sudo -E zypper install"
        abbr -a Prm  "sudo zypper remove -u"
        abbr -a Psi  "sudo -E zypper source-install"
        # update management
        abbr -a Pdup "sudo -E zypper dist-upgrade"
        abbr -a Plu  "zypper list-updates"
        abbr -a Pup  "sudo -E zypper update"
        # querying
        abbr -a Pif  "zypper info"
        #alias Pif="rpm -qi"
        abbr -a Pse  "zypper search"
        abbr -a Pwp  "zypper search --provides"
        #alias Pwp="rpm -q --whatprovides"
        # locking
        abbr -a Pal  "sudo zypper addlock"
        abbr -a Pll  "zypper locks"
        abbr -a Prl  "sudo zypper removelock"
        abbr -a Pcl  "sudo zypper cleanlocks"
        # utilities
        abbr -a Pcln "sudo zypper clean"
        abbr -a Pinr "sudo -E zypper install-new-recommends"
        abbr -a Pps  "zypper ps"
        abbr -a Pve  "sudo -E zypper verify"

        function packman_log
            sudo cut -d "|" -f 1-4 -s --output-delimiter " | " /var/log/zypp/history
        end
    end

    function __ginshio_apt_package_management
        # need 'software-properties-common'
        # repository management
        abbr -a Par  "sudo add-apt-repository"
        abbr -a Plr  "add-apt-repository --list"
        abbr -a Pref "sudo -E apt update"
        abbr -a Prr  "sudo add-apt-repository --remove"
        abbr -a Pmr  "sudo apt edit-sources"
        abbr -a Pnr  "sudo apt edit-sources"
        # package management
        abbr -a Parm "sudo apt autoremove --purge"
        abbr -a Pin  "sudo -E apt install"
        abbr -a Prm  "sudo apt purge"
        abbr -a Psi  "sudo -E apt-src install"
        # update management
        abbr -a Pdup "sudo -E apt dist-upgrade"
        abbr -a Plu  "apt list --upgradable"
        abbr -a Pup  "sudo -E apt upgrade"
        # querying
        abbr -a Pif  "apt show"
        #alias Pif="dpkg -s"
        abbr -a Pse  "apt search"
        abbr -a Pwp  "dpkg -s"
        #alias Pwp="dpkg -s"
        # locking
        abbr -a Pal  "sudo apt-mark hold"
        abbr -a Pll  "apt-mark showhold"
        abbr -a Prl  "sudo apt-mark unhold"
        #abbr -a Pcl  ""
        # utilities
        abbr -a Pcc  "sudo apt clean"
        abbr -a Pinr ""
        abbr -a Pps  ""
        abbr -a Pve  "sudo -E apt check"
    end

    function __ginshio_pacman_package_management
        # repository management
        abbr -a Par  ""
        abbr -a Plr  ""
        abbr -a Pref "sudo -E pacman -Sy"
        abbr -a Prr  ""
        abbr -a Pmr  ""
        abbr -a Pnr  ""
        # package management
        abbr -a Parm "sudo pacman -Qdtq | pacman -Rs -"
        abbr -a Pin  "sudo -E pacman -S"
        abbr -a Prm  "sudo pacman -Rs"
        abbr -a Psi  ""
        # update management
        abbr -a Pdup "sudo -E pacman -Syu"
        abbr -a Plu  "pacman -Qu"
        abbr -a Pup  "sudo -E pacman -Syu"
        # querying
        abbr -a Pif  "pacman -Si"
        #alias Pif="pacman -Qi"
        abbr -a Pse  "pacman -Ss"
        abbr -a Pwp  "pacman -Sii"
        #alias Pwp="pacman -Qii"
        # locking
        abbr -a Pal  ""
        abbr -a Pll  ""
        abbr -a Prl  ""
        abbr -a Pcl  ""
        # utilities
        abbr -a Pcln "sudo pacman -Scc"
        abbr -a Pinr ""
        abbr -a Pps  ""
        abbr -a Pve  "pacman -Dk"
    end

    __ginshio_command_abbreviation

    switch (/bin/bash -c ". /etc/os-release; echo \"\${NAME:-\${DISTRIB_ID}} \${VERSION_ID:-\${DISTRIB_RELEASE}}\"")
        # case 'FreeBSD*'
        #    __ginshio_freebsd_package_management
        # case 'CentOS*' 'Fedora*' 'Oracle*' 'openEuler*'
        #    __ginshio_dnf_package_management
        case 'Debian*' 'Ubuntu*' 'Kali*' 'Deepin*'
            __ginshio_apt_package_management
        case 'openSUSE*'
            __ginshio_zypp_package_management
        case 'Arch*'
            __ginshio_pacman_package_management
        case '*'
            echo "unknown $distro"
    end

    set __ginshio_kernel_name (uname -mrs |tr '[:upper:]' '[:lower:]')
    switch $__ginshio_kernel_name
        case '*microsoft*'
            # Microsoft WSL Environment
            set -g hostip (ip route|awk '/^default/{print $3}')
            set -g loaclip (ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
            set -x DISPLAY "$hostip:0"
            set -x INPUT_METHOD fcitx
            set -x XMODIFIERS "@im=fcitx"
            set -x GTK_IM_MODULE fcitx
            set -x QT_IM_MODULE fcitx
            daemonize -e /tmp/fcitx5.log -o /tmp/fcitx5.log -p /tmp/fcitx5.pid -l /tmp/fcitx5.pid -a /usr/bin/fcitx5 --disable=wayland
            function proxy
                set -x -g http_proxy  "http://$hostip:8118"
                set -x -g https_proxy "http://$hostip:8118"
            end

            for p in $PATH
                switch (wslpath -m $p)
                    case '//wsl*'
                        set -p __ginshio_wsl_path $p
                    case '*'
                        set -p __ginshio_wsl_cleaned_path $p
                end
            end
            set -x -g PATH $__ginshio_wsl_path
        case '*'
            function proxy
                set -xg no_proxy "localhost,127.0.0.1,localaddress,.localdomain.com,.cn"
                set -xg http_proxy  "http://localhost:8118"
                set -xg https_proxy "http://localhost:8118"
            end
    end
end
