#!/usr/bin/env bash

mkdir -p $HOME/Projects

git config --global user.name "$USERNAME"
git config --global user.email "$USEREMAIL"

CMAKE_OPTIONS=(
  "-GNinja Multi-Config"
  -DCMAKE_DEFAULT_BUILD_TYPE=Release
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
  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON
)

### mesa
git clone https://gitlab.freedesktop.org/mesa/mesa.git $HOME/Projects/mesa
CC='ccache gcc' CXX='ccache g++' CFLAGS='-flto' CXXFLAGS='-flto' LDFLAGS='-fuse-ld=mold' \
    meson setup $HOME/Projects/mesa $HOME/Projects/mesa/_build/_rel \
    --libdir=lib --prefix $HOME/.local -Dbuildtype=release \
    -Dgallium-drivers=radeonsi,zink,llvmpipe -Dvulkan-drivers=amd,swrast \
    -Dgallium-opencl=disabled -Dgallium-rusticl=false
meson compile -C $HOME/Projects/mesa/_build/_rel && meson install -C $_
CC='ccache gcc' CXX='ccache g++' LDFLAGS='-fuse-ld=mold' \
    meson setup $HOME/Projects/mesa $HOME/Projects/mesa/_build/_dbg \
    --libdir=lib --prefix $HOME/Projects/mesa/_build/_dbg -Dbuildtype=debug \
    -Dgallium-drivers=radeonsi,zink,llvmpipe -Dvulkan-drivers=amd,swrast \
    -Dgallium-opencl=disabled -Dgallium-rusticl=false
meson compile -C $HOME/Projects/mesa/_build/_dbg && meson install -C $_
# MESA_ROOT=$HOME/.local \
#       LD_LIBRARY_PATH=$MESA_ROOT/lib LIBGL_DRIVERS_PATH=$MESA_ROOT/lib/dri \
#       VK_DRIVER_FILES=$(eval echo "$MESA_ROOT/share/vulkan/icd.d/{radeon,lvp}_icd.x86_64.json" |tr ' ' ':') \
#       MESA_SHADER_CACHE_DISABLE=true MESA_LOADER_DRIVER_OVERRIDE=radeonsi LIBGL_ALWAYS_SOFTWARE= VK_LOADER_DRIVERS_DISABLE= \
#       RADV_DEBUG=nocache RADV_PERFTEST= \
#       AMD_DEBUG= \
#       LP_DEBUG= LP_PERF= \
#       ACO_DEBUG= NIR_DEBUG= \
#       dosomething
#### If disable radv: VK_LOADER_DRIVERS_DISABLE='radeon*'

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

### vkd3d-proton
git clone https://github.com/HansKristian-Work/vkd3d-proton.git --recursive $HOME/Projects/vkd3d
CC='ccache gcc' CXX='ccache g++' LDFLAGS='-fuse-ld=mold' \
    meson setup $HOME/Projects/vkd3d $HOME/Projects/vkd3d/_build/_rel \
    -Dbuildtype=release -Denable_tests=true -Denable_extras=false
meson compile -C $HOME/Projects/vkd3d/_build/_rel

### slang
git clone https://github.com/shader-slang/slang.git --recursive $HOME/Projects/slang
cmake -S$HOME/Projects/slang -B$HOME/Projects/slang/_build "${CMAKE_OPTIONS[@]}" -DSLANG_SLANG_LLVM_FLAVOR=DISABLE
cmake --build $HOME/Projects/slang/_build --config Release

### LLVM
git clone https://github.com/llvm/llvm-project.git $HOME/Projects/llvm
llvm_num_link=$(awk '/MemTotal/{targets = int($2 / (16 * 2^20)); print targets<1?1:targets}' /proc/meminfo)
cmake -S$HOME/Projects/llvm/llvm -B$HOME/Projects/llvm/_build/_dbg -DCMAKE_BUILD_TYPE=Debug \
    -GNinja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_BUILD_TESTS=ON \
    -DLLVM_BUILD_TOOLS=ON \
    -DLLVM_CCACHE_BUILD=ON \
    -DLLVM_ENABLE_PIC=ON \
    -DLLVM_ENABLE_PROJECTS='clang;mlir' \
    -DLLVM_INCLUDE_TOOLS=ON \
    -DLLVM_OPTIMIZED_TABLEGEN=ON \
    -DLLVM_PARALLEL_LINK_JOBS:STRING=$llvm_num_link \
    -DLLVM_TARGETS_TO_BUILD='AMDGPU;RISCV;X86' \
    -DLLVM_USE_LINKER=mold \


### UMR
git clone https://gitlab.freedesktop.org/tomstdenis/umr.git $HOME/Projects/umr
cmake -S$HOME/Projects/umr -B$HOME/Projects/umr/_build "${CMAKE_OPTIONS[@]}"
cmake --build $HOME/Projects/umr/_build --config Release
rsync $HOME/Projects/umr/_build/src/app/Release/umr $HOME/.local/bin

### develop scripts
DEVELOP_AUTOSTART_NAME=develop.$USER
cat <<-EOF >$HOME/.config/autostart/$DEVELOP_AUTOSTART_NAME.sh
#!/usr/bin/env bash

tmux new-session -d -s runner -c $XDG_RUNTIME_DIR/runner
tmux new-session -d -s build -c $HOME/Projects

cat <<-VKEXCLUDE >$XDG_RUNTIME_DIR/runner/deqp/vk-exclude.txt
api.txt
image/swapchain-mutable.txt
info.txt
query-pool.txt
video.txt
wsi.txt
VKEXCLUDE
tmux send-keys -t runner "copy_graphics_testcase --deqp --piglit --tool --vkd3d" ENTER
EOF
cat <<-EOF >$HOME/.config/autostart/$DEVELOP_AUTOSTART_NAME.desktop
[Desktop Entry]
Name=development directory settings
Exec=/usr/bin/bash $HOME/.config/autostart/$DEVELOP_AUTOSTART_NAME.sh
Type=Application
Categories=Development;Utility;
X-KDE-autostart-phase=2
X-GNOME-Autostart-Phase=Panel
EOF
DEVELOP_DRIVER_ENV_NAME=.driver.env
cat <<-EOF >$HOME/.config/autostart/$DEVELOP_DRIVER_ENV_NAME
AMDVLK_ICD_PATH=$HOME/Projects/amdvlk/_icd/rel.json
AMDVLK_PATH=\$(sed -nE '/"library_path"/ {s/.*: "(.*)".*/\1/p;q}' \$AMDVLK_ICD_PATH)
RADV_ICD_PATH=$HOME/.local/share/vulkan/icd.d/radeon_icd.x86_64.json
RADV_PATH=\$(sed -nE '/"library_path"/ {s/.*: "(.*)".*/\1/p;q}' \$RADV_ICD_PATH)
MESA_ROOT=$HOME/.local/lib
RADEONSI_PATH=$MESA_ROOT/dri/radeonsi_dri.so
EOF



### daily test scripts
DAILY_TEST_NAME=daily.test.$USER
cat <<-EOF >$HOME/.config/autostart/$DAILY_TEST_NAME.sh
#!/usr/bin/env bash

export XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR
RUNNER_DIR=\$XDG_RUNTIME_DIR/runner
set -o allexport
source $HOME/.config/autostart/$DEVELOP_DRIVER_ENV_NAME
set +o allexport

SUFFIX=_\$(date "+%Y-%m-%d")
DEVICE_ID=\$(vulkaninfo 2>/dev/null |awk '/deviceID[[:blank:]]*=/ {print \$NF; exit}')
AVAILABLE_CPUS_CNT=$(cnt=$(bc <<<"($(lscpu -e |wc -l) - 1) * 0.8 / 1"); echo $(($cnt > 0 ? $cnt : 1)))

function get_repo_sha1() {
    touch git-sha1.txt
    if [ "\$glapi" = "zink" ] || [ "\$vendor" = "mesa" ]
    then echo " + mesa: \$(git -C $HOME/Projects/mesa rev-parse --short=11 HEAD)" >>git-sha1.txt
    fi
    echo " + \$testkit: \$(git -C $HOME/Projects/\$testkit rev-parse --short=11 HEAD)" >>git-sha1.txt
}

function test_kits_deqp() {
    deqp_options='--deqp-log-images=disable --deqp-log-shader-sources=disable --deqp-log-decompiled-spirv=disable --deqp-shadercache=disable'
    result_files=(
        flakes.txt
        git-sha1.txt
        testlist.txt
    )
    case \$glapi in
        vk)
            exe_name=deqp-vk
            case_lists=(
                \$RUNNER_DIR/deqp/mustpass/vk-default/{binding-model,descriptor-indexing}.txt
                \$RUNNER_DIR/deqp/mustpass/vk-default/{image/*,robustness,sparse-resources,ssbo,texture,ubo}.txt
                \$RUNNER_DIR/deqp/mustpass/vk-default/compute.txt
                \$RUNNER_DIR/deqp/mustpass/vk-default/tessellation.txt
                \$RUNNER_DIR/deqp/mustpass/vk-default/geometry.txt
                \$RUNNER_DIR/deqp/mustpass/vk-default/{clipping,transform-feedback}.txt
                \$RUNNER_DIR/deqp/mustpass/vk-default/mesh-shader.txt
                \$RUNNER_DIR/deqp/mustpass/vk-default/{depth,fragment-*}.txt
                \$RUNNER_DIR/deqp/mustpass/vk-default/{ray-tracing-pipeline,ray-query}.txt
                \$RUNNER_DIR/deqp/mustpass/vk-default/pipeline/*.txt
                #\$RUNNER_DIR/deqp/mustpass/vk-default/{conditional-rendering,dynamic-rendering,renderpass{,2}}.txt
                \$RUNNER_DIR/deqp/mustpass/vk-default/{reconvergence,subgroups}.txt
                #\$RUNNER_DIR/deqp/mustpass/vk-default/dgc.txt
            )
            ext_files=(dEQP-VK.info.device)
            runner_options=(
                "--jobs \$AVAILABLE_CPUS_CNT"
                "--tests-per-group 4096"
                "--timeout 300.0"
            )
            ext_deqp_options=()
            ;;
        gl|zink)
            exe_name=glcts
            case_lists=(
                #\$RUNNER_DIR/deqp/mustpass/{egl,gl,gles}/aosp_mustpass/main/*-main.txt
                \$RUNNER_DIR/deqp/mustpass/gl{,es}/khronos_mustpass/main/*-main.txt
                \$RUNNER_DIR/deqp/mustpass/gl/khronos_mustpass_single/main/*-single.txt
            )
            ext_files=()
            runner_options=(
                "--jobs \$AVAILABLE_CPUS_CNT"
                "--timeout 300.0"
            )
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
    \$RUNNER_DIR/deqp-runner run \\
        \${runner_options[@]} \\
        --deqp \$RUNNER_DIR/\$testkit/\$exe_name \\
        --output \$output_dir \\
        --caselist \${case_lists[@]} \\
        --env \${env_lists[@]} \\
        -- \\
        \$deqp_options \${ext_deqp_options[@]}
    cd \$output_dir
    get_repo_sha1
    ls -1 \${case_lists[@]} |sed "s~\$RUNNER_DIR/\$testkit/mustpass/~~g" >testlist.txt
    awk -F, '\$2 == "Flake"{print \$1}' results.csv >flakes.txt
    tar -H pax -cf - {failures,results}.csv \$(eval echo \${result_files[@]}) \${ext_files[@]} | \\
        zstd -z -19 --ultra --quiet -o \${tarball_name}.tar.zst
} # test_kits_deqp function end

function test_kits_piglit() {
    runner_options=(
        "--jobs \$AVAILABLE_CPUS_CNT"
        "--timeout 300"
    )
    result_files=(
        flakes.txt
        git-sha1.txt
    )
    \$RUNNER_DIR/piglit-runner run \\
        \${runner_options[@]} \\
        --piglit-folder \$RUNNER_DIR/piglit \\
        --output \$output_dir \\
        --env \${env_lists[@]} \\
        --profile quick \\
        -- \\

    cd \$output_dir
    get_repo_sha1
    awk -F, '\$2 == "Flake"{print \$1}' results.csv >flakes.txt
    tar -H pax -cf - {failures,results}.csv \$(eval echo \${result_files[@]}) | \\
        zstd -z -19 --ultra --quiet -o \${tarball_name}.tar.zst
} # test_kits_piglit function end

function test_kits_vkd3d() {
    declare -x \${env_lists[@]}
    VKD3D_SHADER_CACHE_PATH=0 \\
    bash \$RUNNER_DIR/vkd3d/tests/test-runner.sh \\
        --output-dir \$output_dir \\
        --jobs \$AVAILABLE_CPUS_CNT \\
        \$RUNNER_DIR/vkd3d/bin/d3d12 >\$output_dir-results.txt
    cd \$output_dir
    get_repo_sha1
    mv \$output_dir-results.txt results.txt
    tar -H pax -cf - results.txt git-sha1.txt *.log | \\
        zstd -z -19 --ultra --quiet -o \${tarball_name}.tar.zst
} # test_kits_vkd3d function end

declare -a test_infos=\$1
for elem in \${test_infos[@]}; do
    IFS=',' read vendor glapi testkits <<< "\${elem}"
    case \$vendor in
        mesa)
            env_lists=(
                VK_ICD_FILENAMES=\$RADV_ICD_PATH
                __GLX_FORCE_VENDOR_LIBRARY_0=mesa
                LD_LIBRARY_PATH=\$MESA_ROOT
                LIBGL_DRIVERS_PATH=\$MESA_ROOT/dri
                MESA_LOADER_DRIVER_OVERRIDE=radeonsi
                RADV_DEBUG=nocache
                AMD_DEBUG=
                NIR_DEBUG=
            )
            ;;
        llpc)
            env_lists=(
                VK_ICD_FILENAMES=\$AMDVLK_ICD_PATH
            )
            ;;
        *)
            exit -1
            ;;
    esac
    case \$glapi in
        zink)
            env_lists+=(
                __GLX_FORCE_VENDOR_LIBRARY_0=mesa
                LD_LIBRARY_PATH=\$MESA_ROOT
                LIBGL_DRIVERS_PATH=\$MESA_ROOT/dri
                MESA_LOADER_DRIVER_OVERRIDE=zink
            )
            ;;
        *)
            ;;
    esac
    for testkit in \$(tr ':' '\\t' <<<\$testkits); do
        tarball_name=\${testkit}-\${glapi}_\${DEVICE_ID}\${SUFFIX}
        output_dir=\$RUNNER_DIR/baseline/\${vendor}_\${testkit}-\${glapi}\${SUFFIX}
        test_kits_\$testkit
    done # test kits loop end
done # test infos loop end
EOF



### daily running
DAILY_SCRIPT_NAME=daily.$USER
cat <<-EOF >$HOME/.config/autostart/$DAILY_SCRIPT_NAME.sh
#!/usr/bin/env bash

sudo -Sv <<<"$ROOT_PASSPHRASE"
sudo -E zypper ref
sudo -E zypper dup -y
sudo cp /etc/hosts.bkp /etc/hosts
sudo bash -c "curl -s https://gitlab.com/ineo6/hosts/-/raw/master/next-hosts |sed '1,2d' - |tee -a /etc/hosts"

export PATH=$HOME/.local/bin:\$PATH

now_timestamps=\$(date +%s)
set -o allexport
source $HOME/.config/autostart/$DEVELOP_DRIVER_ENV_NAME
set +o allexport
drivers_tuple=(
    # vendor,glapi,kits,driver
    llpc,vk,"deqp",\$AMDVLK_PATH
    mesa,vk,"deqp",\$RADV_PATH
    llpc,zink,"deqp",\$AMDVLK_PATH
    mesa,zink,"deqp",\$RADV_PATH
    #mesa,gl,"deqp:piglit",\$RADEONSI_PATH
) # drivers tuple declare end

pushd $HOME/Projects/mesa
{ git fetch --all --prune && git merge --ff-only origin/main; } >/dev/null 2>&1
if [ \$? -eq 0 ]; then
    meson compile -C _build/_rel && meson install --quiet -C \$_
    meson compile -C _build/_dbg && meson install --quiet -C \$_
fi
popd

pushd $HOME/Projects/umr
{ git fetch --all --prune && git merge --ff-only origin/main; } >/dev/null 2>&1
if [ \$? -eq 0 ]; then
    cmake --build _build --config Release
    rsync $HOME/Projects/umr/_build/src/app/Release/umr $HOME/.local/bin
fi
popd

fd -iHx /usr/bin/rm -rf {} \\; --changed-before 3d --type directory -- . '$XDG_RUNTIME_DIR/runner/baseline'

# Testing only on Monday or Thursday
{ date +%A |grep -qi -e Monday -e Thursday; } || exit 0

declare -a test_infos=()
for elem in \${drivers_tuple[@]}; do
    IFS=',' read vendor glapi testkits driver <<< "\${elem}"
    if ! [ -e \$driver ] || [ \$now_timestamps -ge \$(stat -c "%Y" "\$driver") ]; then
        continue
    fi
    test_infos+=("\$vendor,\$glapi,\$testkits")
done
tmux send-keys -t runner "bash $HOME/.config/autostart/$DAILY_TEST_NAME.sh '\${test_infos[*]}'" ENTER

#systemctl reboot
EOF
