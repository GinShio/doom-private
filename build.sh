#!/usr/bin/env bash

mkdir -p $HOME/Projects

source $HOME/.setup-info.txt
echo ${USERNAME:?Missing User Name.} >/dev/null
echo ${USEREMAIL:?Missing User email.} >/dev/null
echo ${ROOT_PASSPHRASE:?Missing local host root passphrase.} >/dev/null

git config --global user.name "$USERNAME"
git config --global user.email "$USEREMAIL"

CMAKE_OPTIONS=(
  "-GNinja Multi-Config"
  -DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=mold
  -DCMAKE_SHARED_LINKER_FLAGS=-fuse-ld=mold
  -DCMAKE_MODULE_LINKER_FLAGS=-fuse-ld=mold
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
  -DCMAKE_C_COMPILER_LAUNCHER=ccache
  -DCMAKE_C_COMPILER=gcc
  -DCMAKE_C_FLAGS_INIT=-fdiagnostics-color=always
  -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
  -DCMAKE_CXX_COMPILER=g++
  -DCMAKE_CXX_FLAGS_INIT=-fdiagnostics-color=always
)

### mesa
git clone https://gitlab.freedesktop.org/mesa/mesa.git $HOME/Projects/mesa
CC='ccache gcc' CXX='ccache g++' LDFLAGS='-fuse-ld=mold' \
    meson setup $HOME/Projects/mesa $HOME/Projects/mesa/_build \
    --libdir=lib64 --prefix $HOME/.local -Dbuildtype=release \
    -Dgallium-drivers=radeonsi,zink,swrast -Dvulkan-drivers=amd,swrast \
    -Dgallium-opencl=disabled -Dgallium-rusticl=false
meson compile -C$HOME/Projects/mesa/_build && meson install -C$HOME/Projects/mesa/_build
PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/local/lib/pkgconfig \
    CC='ccache gcc -m32' CXX='ccache g++ -m32' LDFLAGS='-fuse-ld=mold -m32' \
    meson setup $HOME/Projects/mesa $HOME/Projects/mesa/_build32 \
    --libdir=lib --prefix $HOME/.local -Dbuildtype=release \
    -Dgallium-drivers=radeonsi,zink,swrast -Dvulkan-drivers=amd,swrast \
    -Dgallium-opencl=disabled -Dgallium-rusticl=false
meson compile -C$HOME/Projects/mesa/_build32 && meson install -C$HOME/Projects/mesa/_build32

### vk-gl-cts
# git clone https://github.com/KhronosGroup/VK-GL-CTS.git $HOME/Projects/deqp
# cd $HOME/Projects/deqp
# python3 external/fetch_sources.py
# cmake -S$HOME/Projects/deqp -B$HOME/Projects/deqp/_build "${CMAKE_OPTIONS[@]}" -DDEQP_TARGET=default
# cmake --build $HOME/Projects/deqp/_build --config Release

### piglit
git clone https://gitlab.freedesktop.org/mesa/piglit.git $HOME/Projects/piglit
cmake -S$HOME/Projects/piglit -B$HOME/Projects/piglit/_build "${CMAKE_OPTIONS[@]}"
cmake --build $HOME/Projects/piglit/_build --config Release

### deqp-runner
git clone https://gitlab.freedesktop.org/mesa/deqp-runner.git $HOME/Projects/runner
cd $HOME/Projects/runner
cargo build --release --target-dir $HOME/Projects/runner/_build

### boost
cd $(mktemp -d)
curl -o boost_1_84_0.tar.gz -SL https://archives.boost.io/release/1.84.0/source/boost_1_84_0.tar.gz
tar --gzip -xf boost_1_84_0.tar.gz && cd boost_1_84_0
pushd tools/build
bash ./bootstrap.sh
popd
tools/build/b2 toolset=gcc variant=release cflags=-fPIC cxxflags=-fPIC link=shared install --prefix=$HOME/.local --build-type=complete --layout=versioned --build-dir=_build --without-python
tools/build/b2 toolset=gcc variant=release cflags=-fPIC cxxflags=-fPIC link=static install --prefix=$HOME/.local --build-type=complete --layout=versioned --build-dir=_build --without-python



### develop scripts
DEVELOP_AUTOSTART_NAME=develop.$USER
cat <<-EOF >$HOME/.config/autostart/$DEVELOP_AUTOSTART_NAME.sh
#!/usr/bin/env bash

rsync $HOME/Projects/runner/_build/release/{deqp,piglit}-runner $XDG_RUNTIME_DIR/runner

DEQP_SRCDIR=$HOME/Projects/deqp
DEQP_DSTDIR=$XDG_RUNTIME_DIR/runner/deqp
rsync \$DEQP_SRCDIR/_build/external/vulkancts/modules/vulkan/Release/deqp-vk \$DEQP_DSTDIR
rsync -rR \$DEQP_SRCDIR/external/vulkancts/data/./vulkan \$DEQP_DSTDIR
rsync -rR \$DEQP_SRCDIR/external/vulkancts/mustpass/main/./vk-default{,.txt} \$DEQP_DSTDIR/mustpass
rsync \$DEQP_SRCDIR/_build/external/openglcts/modules/Release/glcts \$DEQP_DSTDIR
rsync -rR \$DEQP_SRCDIR/_build/external/openglcts/modules/./gles{2,3,31}/{data,shaders} \$DEQP_DSTDIR
rsync -rR \$DEQP_SRCDIR/_build/external/openglcts/modules/./gl_cts/data/GTF \$DEQP_DSTDIR
rsync -rR \$DEQP_SRCDIR/external/graphicsfuzz/data/./gles3/graphicsfuzz/ \$DEQP_DSTDIR
rsync -rR --exclude='mustpass' \$DEQP_SRCDIR/external/openglcts/data/./gl_cts \$DEQP_DSTDIR
rsync -rR --exclude='src' \$DEQP_SRCDIR/external/openglcts/data/gl_cts/data/mustpass/./{egl,gl,gles}/*mustpass*/main/*.txt \$DEQP_DSTDIR/mustpass
rsync -rR \$DEQP_SRCDIR/external/openglcts/data/gl_cts/data/mustpass/./waivers \$DEQP_DSTDIR/mustpass

PIGLIT_SRCDIR=$HOME/Projects/piglit
PIGLIT_DSTDIR=$XDG_RUNTIME_DIR/runner/piglit
rsync -rR \$PIGLIT_SRCDIR/_build/./bin \$PIGLIT_DSTDIR
rsync -rR \$PIGLIT_SRCDIR/./{framework,templates} \$PIGLIT_DSTDIR
rsync -rR \$PIGLIT_SRCDIR/_build/./tests/*.xml.gz \$PIGLIT_DSTDIR
rsync -mrR -f'- *.[chao]' -f'- *.[ch]pp' -f'- *[Cc][Mm]ake*' \$PIGLIT_SRCDIR/./tests \$PIGLIT_DSTDIR
rsync -rR \$PIGLIT_SRCDIR/./generated_tests/**.inc \$PIGLIT_DSTDIR
rsync -mrR -f'- *.[chao]' -f'- *.[ch]pp' -f'- *[Cc][Mm]ake*' \$PIGLIT_SRCDIR/_build/./generated_tests \$PIGLIT_DSTDIR

tmux new-session -d -s runner -c $XDG_RUNTIME_DIR/runner
EOF
cat <<-EOF >$HOME/.config/autostart/$DEVELOP_AUTOSTART_NAME.desktop
[Desktop Entry]
Name=development directory settings
Exec=/usr/bin/env bash $HOME/.config/autostart/$DEVELOP_AUTOSTART_NAME.sh
Type=Application
Categories=Development;Utility;
X-KDE-autostart-phase=2
X-GNOME-Autostart-Phase=Panel
EOF



### daily test scripts
DAILY_TEST_NAME=daily.test.$USER
cat <<-EOF >$HOME/.config/autostart/$DAILY_TEST_NAME.sh
#!/usr/bin/env bash

export XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR

RUNNER_DIR=\$XDG_RUNTIME_DIR/runner
SUFFIX=_\$(date --iso-8601="date")

DEVICE_ID=\$(vulkaninfo 2>/dev/null |awk '/deviceID[[:blank:]]*=/ {print \$NF; exit}')
RUNNER_OPTIONS="--jobs $(perl -e "print int($(( $(lscpu -e |wc -l) - 1 )) * 0.8)") --timeout 240.0"
DEQP_OPTIONS='--deqp-log-images=disable --deqp-log-shader-sources=disable --deqp-log-decompiled-spirv=disable --deqp-shadercache=disable'
RESULT_FILES=(
    git-sha1.txt
    testlist.txt
)

deqp_runner_set=(vk)
driver_vendor_set=(llpc)
for glapi in \${deqp_runner_set[@]}; do
    case \$glapi in
        vk)
            exe_name=deqp-vk
            case_lists=(
                \$RUNNER_DIR/deqp/mustpass/vk-default/{binding-model,descriptor-indexing,sparse-resources}.txt
                \$RUNNER_DIR/deqp/mustpass/vk-default/compute.txt
                #\$RUNNER_DIR/deqp/mustpass/vk-default/{conditional-rendering,dynamic-rendering}.txt
                \$RUNNER_DIR/deqp/mustpass/vk-default/image/{depth-stencil,load-store,sample,store}*.txt
                \$RUNNER_DIR/deqp/mustpass/vk-default/pipeline/monolithic.txt
                \$RUNNER_DIR/deqp/mustpass/vk-default/{ray-tracing-pipeline,ray-query}.txt
                #\$RUNNER_DIR/deqp/mustpass/vk-default/{reconvergence,renderpass{,2},robustness}.txt
                \$RUNNER_DIR/deqp/mustpass/vk-default/{reconvergence,robustness}.txt
                \$RUNNER_DIR/deqp/mustpass/vk-default/{ssbo,texture,ubo}.txt
            )
            ext_files=(dEQP-VK.info.device)
            ext_runner_options=(
                "--tests-per-group 4096"
            )
            ext_deqp_options=()
            ;;
        gl)
            exe_name=glcts
            case_lists=(
                \$RUNNER_DIR/deqp/mustpass/{egl,gl,gles}/aosp_mustpass/main/*-main.txt
                \$RUNNER_DIR/deqp/mustpass/gl{,es}/khronos_mustpass/main/*-main.txt
            )
            ext_files=()
            ext_runner_options=()
            ext_deqp_options=(
                --deqp-gl-config-name=rgba8888d24s8ms0
                --deqp-surface-{height,width}=256
                --deqp-visibility=hidden
            )
            ;;
        *)
            exit -1
            ;;
    esac
    for vendor in \${driver_vendor_set[@]}; do
        case \$vendor in
            mesa)
                MESA_ROOT=$HOME/.local
                env_lists=(
                    VK_ICD_FILENAMES=\$MESA_ROOT/share/vulkan/icd.d/radeon_icd.x86_64.json:\$MESA_ROOT/share/vulkan/icd.d/radeon_icd.i686.json
                    LD_LIBRARY_PATH=\$MESA_ROOT/lib64:\$MESA_ROOT/lib
                    LIBGL_DRIVERS_PATH=\$MESA_ROOT/lib64/dri:\$MESA_ROOT/lib/dri
                    MESA_LOADER_DRIVER_OVERRIDE=radeonsi
                    RADV_DEBUG=nocache
                    AMD_DEBUG=
                    NIR_DEBUG=
                )
                ;;
            llpc)
                env_lists=(
                    VK_ICD_FILENAMES=$HOME/Projects/amdvlk/_icd/rel.json
                )
                ;;
            *)
                exit -1
                ;;
        esac

        output_dir=\${vendor}_deqp-\${glapi}\${SUFFIX}
        tarball_name=deqp-\${glapi}_\${DEVICE_ID}\${SUFFIX}
        \$RUNNER_DIR/deqp-runner run \\
            \$RUNNER_OPTIONS \${ext_runner_options[@]} \\
            --deqp \$RUNNER_DIR/deqp/\$exe_name \\
            --output \$RUNNER_DIR/baseline/\$output_dir \\
            --caselist \${case_lists[@]} \\
            --env \${env_lists[@]} \\
            -- \\
            \$DEQP_OPTIONS \${ext_deqp_options[@]}
        cd \$RUNNER_DIR/baseline/\$output_dir
        ls -1 \${case_lists[@]} |sed "s~\$RUNNER_DIR/mustpass/~~g" >testlist.txt
        tar -H pax -cf - {failures,results}.csv \$(eval echo \${RESULT_FILES[@]}) \${ext_files[@]} | \\
            zstd -z -19 --ultra --quiet -o \${tarball_name}.tar.zst
    done
done
EOF



### daily running
DAILY_SCRIPT_NAME=daily.$USER
cat <<-EOF >$HOME/.config/autostart/$DAILY_SCRIPT_NAME.sh
#!/usr/bin/env bash

echo $ROOT_PASSPHRASE |sudo -S -E zypper ref
echo $ROOT_PASSPHRASE |sudo -S -E zypper dup -y

echo $ROOT_PASSPHRASE |sudo -S cp /etc/hosts.bkp /etc/hosts
echo $ROOT_PASSPHRASE |sudo -S bash -c "curl https://gitlab.com/ineo6/hosts/-/raw/master/next-hosts |sed '1,4d' - |tee -a /etc/hosts"

export PATH=$HOME/.local/bin:\$PATH

now_timestamps=\$(date +%s)
drivers=(
    \$(sed -nE 's/[[:space:]]*"library_path": "(.*)".*/\1/p' $HOME/Projects/amdvlk/_icd/rel.json |head -1)  # amdvlk
    #\$(sed -nE 's/[[:space:]]*"library_path": "(.*)".*/\1/p' $HOME/.local/share/vulkan/icd.d/radeon_icd.x86_64.json |head -1)  # mesa
    #$HOME/.local/lib64/dri/radeonsi_dri.so
)

for driver in \${drivers[@]}; do
    if ! [ -e \$driver ] || [ \$now_timestamps -ge \$(stat -c "%Y" "\$driver") ]; then
        exit 1
    fi
done
tmux send-keys -t runner 'bash $HOME/.config/autostart/$DAILY_TEST_NAME.sh' ENTER

#systemctl reboot
EOF
cat <<-EOF |sudo tee /var/spool/cron/tabs/$USER
# DO NOT EDIT THIS FILE - edit the master and reinstall.
# ($(mktemp) installed on $(date --iso-8601="seconds"))
# (Cronie version 4.2)
0 6 * * * /usr/bin/bash $HOME/.config/autostart/$DAILY_SCRIPT_NAME.sh
EOF



### user temp files
cat <<-EOF >$HOME/.config/user-tmpfiles.d/$DEVELOP_AUTOSTART_NAME.conf
d   $XDG_RUNTIME_DIR/issues   0700   $USER   $USER   2w
d   $XDG_RUNTIME_DIR/runner   0700   $USER   $USER   -
d   $XDG_RUNTIME_DIR/runner/baseline   0700   $USER   $USER   3d
d   $XDG_RUNTIME_DIR/runner/deqp   0700   $USER   $USER   -
d   $XDG_RUNTIME_DIR/runner/piglit   0700   $USER   $USER   -
EOF



### LSP temp files
LSP_DEV_NAME=lsp.$USR
cat <<-EOF >$HOME/.config/user-tmpfiles.d/$LSP_DEV_NAME.conf
d   $XDG_RUNTIME_DIR/clangd   0700   $USER   $USER   4w
L+  $HOME/.config/clangd   -   -   -   -   $XDG_RUNTIME_DIR/clangd
d   $XDG_RUNTIME_DIR/mesa   0700   $USER   $USER   -
L+  $HOME/Projects/mesa/.cache - - - - $XDG_RUNTIME_DIR/mesa
EOF
