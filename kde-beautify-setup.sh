#!/usr/bin/env bash

BEAUTIFY_DIR=$(mktemp -d)
cd $BEAUTIFY_DIR
mkdir -p $BEAUTIFY_DIR/theme $BEAUTIFY_DIR/plugin $BEAUTIFY_DIR/sddm

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
install_theme WhiteSur vinceliuice WhiteSur-kde master

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
