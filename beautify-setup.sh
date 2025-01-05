#!/usr/bin/env bash

BEAUTIFY_DIR=$(mktemp -d)
mkdir -p $BEAUTIFY_DIR/{font,grub,icon,theme,plugin,sddm}

# Fonts
cd $BEAUTIFY_DIR/font
### opensource Fonts
curl -o $HOME/.local/share/fonts/SourceHanMono.ttc -sSL https://github.com/adobe-fonts/source-han-mono/releases/download/1.002/SourceHanMono.ttc
curl -o JuliaMono.tar.gz -sSL https://github.com/cormullion/juliamono/releases/download/v0.058/JuliaMono.tar.gz
mkdir -p $HOME/.local/share/fonts/Julia-Mono && tar -xzf JuliaMono.tar.gz -C $_
curl -o Hasklig.tar.xz -sSL https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Hasklig.tar.xz
mkdir -p $HOME/.local/share/fonts/Hasklig-Nerd && tar -Jxf Hasklig.tar.xz -C $_
curl -o SourceCodeVar.zip -sSL https://github.com/adobe-fonts/source-code-pro/releases/download/2.042R-u%2F1.062R-i%2F1.026R-vf/VF-source-code-VF-1.026R.zip
unzip SourceCodeVar -d $HOME/.local/share/fonts/Source-Code-Variable
### Microsoft Fonts from github:fphoenix88888/ttf-mswin10-arch
win10_fonts_langs=("japanese" "korean" "zh_cn" "zh_tw" "sea" "thai" "other")
curl -o win10-fonts.tar.gz -sSL https://github.com/fphoenix88888/ttf-mswin10-arch/archive/master.tar.gz
mkdir -p win10-fonts
tar -xzf win10-fonts.tar.gz -C win10-fonts
mkdir -p $HOME/.local/share/fonts/win10-english $HOME/.local/share/licenses/win10-fonts
tar --zstd -xf win10-fonts/ttf-mswin10-arch-master/ttf-ms-win10-10.0.19043.1055-1-any.pkg.tar.zst -C win10-fonts
mv win10-fonts/usr/share/fonts/TTF/* $HOME/.local/share/fonts/win10-english
mv win10-fonts/usr/share/licenses/ttf-ms-win10/license.rtf $HOME/.local/share/licenses/win10-fonts/english-fonts-license.rtf
for lang in ${win10_fonts_langs[@]}; do
    mkdir -p $HOME/.local/share/fonts/win10-$lang
    tar --zstd -xf win10-fonts/ttf-mswin10-arch-master/ttf-ms-win10-$lang-10.0.19043.1055-1-any.pkg.tar.zst -C win10-fonts
    mv win10-fonts/usr/share/fonts/TTF/* $HOME/.local/share/fonts/win10-$lang
    mv win10-fonts/usr/share/licenses/ttf-ms-win10-$lang/license.rtf $HOME/.local/share/licenses/win10-fonts/$lang-fonts-license.rtf
done

# Grub
cd $BEAUTIFY_DIR/grub
GRUB_DIR='grub'
UPDATE_GRUB=''
case $DISTRO_NAME in
    Debian*|Ubuntu*|Kali*|Deepin*)
        #UPDATE_GRUB='update-grub'
        ;;
    Arch*|Manjaro*|Gentoo*)
        #UPDATE_GRUB='grub-mkconfig -o /boot/grub/grub.cfg'
        ;;
    Fedora*|openSUSE*)
        GRUB_DIR='grub2'
        #UPDATE_GRUB="grub2-mkconfig -o /boot/efi/EFI/${DISTRO_ID}/grub.cfg"
        ;;
    *)
       echo Unknown Distro
       exit 1
       ;;
esac
GRUB_PREFIX=/boot/$GRUB_DIR/themes
function install_grub {
    local GRUB_NAME=$1
    local GRUB_AUTHOR=$2
    local GRUB_REPO=$3
    local GRUB_TAG=$4
    local GRUB_SUBDIR=$5
    local GRUB_TEMP_DIR=$BEAUTIFY_DIR/grub/$GRUB_NAME

    echo "install GRUB2 THEME: $GRUB_NAME ..."
    mkdir -p $GRUB_TEMP_DIR
    curl -o $GRUB_NAME.tar.gz -sSL https://github.com/$GRUB_AUTHOR/$GRUB_REPO/archive/$GRUB_TAG.tar.gz
    tar -xzf $GRUB_NAME.tar.gz -C $GRUB_TEMP_DIR
    local source_dir=$GRUB_TEMP_DIR/$GRUB_REPO-$GRUB_TAG
    local dest_dir=$GRUB_PREFIX/$GRUB_NAME

    if [ -f $source_dir/theme.txt ]; then
        :
    elif [ -f $source_dir/$GRUB_NAME/theme.txt ]; then
        local source_dir=$source_dir/$GRUB_NAME
    elif [ -f $source_dir/$GRUB_SUBDIR/theme.txt ]; then
        local source_dir=$source_dir/$GRUB_SUBDIR
    elif [ -f $source_dir/$GRUB_NAME/themes/$GRUB_SUBDIR.tar ]; then
        tar -xf $source_dir/$GRUB_NAME/themes/$GRUB_SUBDIR.tar -C $source_dir/$GRUP_SUBDIR
        local source_dir=$source_dir/$GRUB_SUBDIR

    fi
    sudo mkdir -p $dest_dir
    sudo cp -R $source_dir/* $dest_dir
}
install_grub bigsur Teraskull bigsur-grub2-theme master
install_grub CyberEXS HenriqueLopes42 themeGrub.CyberEXS main
install_grub DistroThemes AdisonCavani distro-grub-themes master 'asus'
install_grub breeze gustawho grub2-theme-breeze master

# Icons
cd $BEAUTIFY_DIR/icon
ICON_PREFIX=$HOME/.local/share/icons
mkdir -p $ICON_PREFIX
function install_icon {
    local ICON_NAME=$1
    local ICON_AUTHOR=$2
    local ICON_REPO=$3
    local ICON_TAG=$4
    local ICON_INSTALL=$5
    local ICON_INSTALL_ARGS=$(echo "$6" |tr ";" "\n")
    local ICON_ALLDIR=$7
    local ICON_PREFIXES=$(echo "$8" |tr ";" "\n")
    local ICON_TEMP_DIR=$BEAUTIFY_DIR/icon/$ICON_NAME

    echo "install ICON & CURSOR: $ICON_NAME ..."
    mkdir -p $ICON_TEMP_DIR
    curl -o $ICON_NAME.tar.gz -sSL https://github.com/$ICON_AUTHOR/$ICON_REPO/archive/$ICON_TAG.tar.gz
    tar -xzf $ICON_NAME.tar.gz -C $ICON_TEMP_DIR
    local source_dir=$ICON_TEMP_DIR/$ICON_REPO-$ICON_TAG

    pushd $source_dir >/dev/null 2>&1
    if [ "$ICON_INSTALL" = "true" ]; then
        bash $source_dir/install.sh ${ICON_INSTALL_ARGS[@]}
    elif [ "$ICON_ALLDIR" = "true" ]; then
        mkdir -p $ICON_PREFIX/$ICON_NAME
        cp -R $source_dir/* $ICON_PREFIX/$ICON_NAME
    elif [[ ${#ICON_PREFIXES[@]} -ne 0 ]]; then
        for prefix in ${ICON_PREFIXES[@]}; do
            cp -R $source_dir/$prefix* $ICON_PREFIX
        done
    else
        cp -R $source_dir/$ICON_NAME* $ICON_PREFIX
    fi
    popd >/dev/null 2>&1
}
install_icon Qogir vinceliuice Qogir-icon-theme master true
install_icon Layan vinceliuice Layan-cursors master true
#install_icon Numix numixproject numix-icon-theme master false
#install_icon Numix-Circle numixproject numix-icon-theme-circle master false
#install_icon Numix-Square numixproject numix-icon-theme-square master false
install_icon Candy EliverLara candy-icons master false "" true
install_icon Papirus PapirusDevelopmentTeam papirus-icon-theme master false "" false "Papirus;ePapirus"
#install_icon Tela vinceliuice Tela-icon-theme master true
#install_icon Deepin zayronxio Deepin-icons-2022 master false "" true
curl -o Bibata.tar.xz -sSL https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/Bibata.tar.xz
mkdir -p $BEAUTIFY_DIR/icon/Bibata
tar -Jxf Bibata.tar.xz -C $BEAUTIFY_DIR/icon/Bibata
cp -R $BEAUTIFY_DIR/icon/Bibata/Bibata-Modern-* $ICON_PREFIX

# Themes
cd $BEAUTIFY_DIR/theme
function install_theme {
    local THEME_NAME=$1
    local THEME_AUTHOR=$2
    local THEME_REPO=$3
    local THEME_TAG=$4
    local THEME_TEMP_DIR=$BEAUTIFY_DIR/theme/$THEME_NAME
    local THEME_SUBDIR=$5
    local THEME_PREFIX=$HOME/.local/share

    echo "install THEME: $THEME_NAME ..."
    mkdir -p $THEME_TEMP_DIR
    curl -o $THEME_NAME.tar.gz -sSL https://github.com/$THEME_AUTHOR/$THEME_REPO/archive/$THEME_TAG.tar.gz
    tar -xzf $THEME_NAME.tar.gz -C $THEME_TEMP_DIR

    local theme_components=(aurorae color-schemes knosole konversation kvantum latte-layout plasma sddm wallpapers yakuake)
    for component in ${theme_components[@]}; do
        local source_dir=$THEME_TEMP_DIR/$THEME_REPO-$THEME_TAG/$THEME_SUBDIR/$component
        local target_dir=$THEME_PREFIX/$component
        sudo mkdir -p $target_dir
        local subdir=themes
        case $component in
            "yakuake")
                local subdir=skins
                ;&
            "aurorae"|"konversation"|"sddm")
                local source_dir=$source_dir/$subdir
                [[ "$component" == "sddm" ]] && local target_dir=/usr/share/$component/$subdir || local target_dir=$target_dir/$subdir
                sudo mkdir -p $target_dir
                [[ -e $source_dir ]] || local source_dir=$(dirname $source_dir)
                ;&
            "color-schemes")
                [[ "$component" == "color-schemes" && ! -e $source_dir ]] && local source_dir=$(dirname $source_dir)/colorschemes
                ;&
            "latte-layout")
                [[ "$component" == "latte-layout" ]] && local target_dir=$HOME/.config/latte
                sudo mkdir -p $target_dir
                ;&
            "wallpapers")
                [[ "$component" == "wallpapers" && ! -e $source_dir ]] && local source_dir=$(dirname $source_dir)/wallpaper
                ;&
            "kvantum")
                [[ "$component" == "kvantum" && ! -e $source_dir ]] && local source_dir=$(dirname $source_dir)/Kvantum
                [[ "$component" == "kvantum" ]] && local target_dir=$HOME/.config/Kvantum
                sudo mkdir -p $target_dir
                ;&
            *)
                [[ -e $source_dir ]] && sudo cp -R $source_dir/* $target_dir
                ;;
        esac
        sudo chown -R $USER:$USER $target_dir
    done
}
install_theme Arc PapirusDevelopmentTeam arc-kde master
install_theme Dracula dracula gtk master kde
install_theme Layan vinceliuice Layan-kde master
#install_theme SweetAmbarBule EliverLara Sweet Ambar-Blue kde
#install_theme WhiteSur vinceliuice WhiteSur-kde master

# Plugins
cd $BEAUTIFY_DIR/plugin
function install_plugin {
    local PLUGIN_NAME=$1
    local PLUGIN_PLATFORM=$2
    local PLUGIN_AUTHOR=$3
    local PLUGIN_REPO=$4
    local PLUGIN_TAG=$5
    local PLUGIN_CATEGRAY=$6
    local PLUGIN_SUBDIR=$7
    local PLUGIN_TEMP_DIR=$BEAUTIFY_DIR/plugin/$PLUGIN_NAME

    echo "install PLUGIN: $PLUGIN_NAME ..."
    mkdir -p $PLUGIN_TEMP_DIR
    case $PLUGIN_PLATFORM in
        "github")
            curl -o $PLUGIN_NAME.tar.gz -sSL https://github.com/$PLUGIN_AUTHOR/$PLUGIN_REPO/archive/$PLUGIN_TAG.tar.gz
            ;;
        "gitlab")
            curl -o $PLUGIN_NAME.tar.gz -sSL https://gitlab.com/$PLUGIN_AUTHOR/$PLUGIN_REPO/-/archive/$PLUGIN_TAG/$PLUGIN_REPO-$PLUGIN_TAG.tar.gz
            ;;
    esac
    tar -xzf $PLUGIN_NAME.tar.gz -C $PLUGIN_TEMP_DIR
    local source_dir=$PLUGIN_TEMP_DIR/$PLUGIN_REPO-$PLUGIN_TAG/$PLUGIN_SUBDIR
    kpackagetool6 --type Plasma/$PLUGIN_CATEGRAY --install $source_dir
}
# install_plugin EventCalendar github Zren plasma-applet-eventcalendar master Applet package
# install_plugin LatteSeparator github psifidotos applet-latte-separator master Applet
# install_plugin WindowTitle github psifidotos applet-window-title master Applet
# install_plugin Win11Menu github prateekmedia Menu11 main Applet
# install_plugin ShaderWallpaper github y4my4my4m kde-shader-wallpaper master Wallpaper
# git clone --depth 1 https://github.com/rbn42/panon.git && pushd panon
# git submodule update --depth 1 --init
# cmake -Stranslations -B_build
# DESTDIR=../plasmoid/contents/locale make -f _build/Makefile install
# kpackagetool5 -t Plasma/Applet --install plasmoid
# popd
# curl -o panon-shaders.tar.gz -SL https://github.com/rbn42/panon-effects/archive/master.tar.gz
# mkdir -p panon-shaders $HOME/.config/panon
# tar -xzf panon-shaders.tar.gz -C panon-shaders
# cp -R panon-shaders/panon-effects-master/effects/rbn42-* $HOME/.config/panon
