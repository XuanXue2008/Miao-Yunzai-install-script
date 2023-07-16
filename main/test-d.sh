## 定义系统判定变量
SYSTEM_DEBIAN="Debian"
SYSTEM_UBUNTU="Ubuntu"
SYSTEM_KALI="Kali"
SYSTEM_REDHAT="RedHat"
SYSTEM_RHEL="Red Hat Enterprise Linux"
SYSTEM_CENTOS="CentOS"
SYSTEM_CENTOS_STREAM="CentOS Stream"
SYSTEM_ROCKY="Rocky"
SYSTEM_ALMALINUX="AlmaLinux"
SYSTEM_FEDORA="Fedora"
SYSTEM_OPENCLOUDOS="OpenCloudOS"
SYSTEM_OPENEULER="openEuler"
SYSTEM_OPENSUSE="openSUSE"
SYSTEM_ARCH="Arch"
## 定义目录和文件
File_LinuxRelease=/etc/os-release
File_RedHatRelease=/etc/redhat-release
File_OpenCloudOSRelease=/etc/opencloudos-release
File_openEulerRelease=/etc/openEuler-release
File_ArchRelease=/etc/arch-release
File_DebianVersion=/etc/debian_version
File_DebianSourceList=/etc/apt/sources.list
File_DebianSourceListBackup=/etc/apt/sources.list.bak
Dir_DebianExtendSource=/etc/apt/sources.list.d
Dir_DebianExtendSourceBackup=/etc/apt/sources.list.d.bak
File_ArchMirrorList=/etc/pacman.d/mirrorlist
File_ArchMirrorListBackup=/etc/pacman.d/mirrorlist.bak
Dir_YumRepos=/etc/yum.repos.d
Dir_YumReposBackup=/etc/yum.repos.d.bak
Dir_openSUSERepos=/etc/zypp/repos.d
Dir_openSUSEReposBackup=/etc/zypp/repos.d.bak
## 定义颜色变量
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PLAIN='\033[0m'
BOLD='\033[1m'
SUCCESS='[\033[32mOK\033[0m]'
COMPLETE='[\033[32mDONE\033[0m]'
WARN='[\033[33mWARN\033[0m]'
ERROR='[\033[31mERROR\033[0m]'
WORKING='[\033[34m*\033[0m]'
## 报错退出
function Output_Error() {
    [ "$1" ] && echo -e "\n$ERROR $1\n"
    exit 1
}
## 权限判定
function PermissionJudgment() {
    if [ $UID -ne 0 ]; then
        Output_Error "权限不足，请使用 Root 用户运行本脚本"
    fi
}
##判断系统版本
function EnvJudgment() {
    ## 定义系统名称
    SYSTEM_NAME="$(cat $File_LinuxRelease | grep -E "^NAME=" | awk -F '=' '{print$2}' | sed "s/[\'\"]//g")"
    cat $File_LinuxRelease | grep "PRETTY_NAME=" -q
    [ $? -eq 0 ] && SYSTEM_PRETTY_NAME="$(cat $File_LinuxRelease | grep -E "^PRETTY_NAME=" | awk -F '=' '{print$2}' | sed "s/[\'\"]//g")"
    ## 定义系统版本号
    SYSTEM_VERSION_NUMBER="$(cat $File_LinuxRelease | grep -E "^VERSION_ID=" | awk -F '=' '{print$2}' | sed "s/[\'\"]//g")"
    ## 定义系统ID
    SYSTEM_ID="$(cat $File_LinuxRelease | grep -E "^ID=" | awk -F '=' '{print$2}' | sed "s/[\'\"]//g")"
    ## 判定当前系统派系（Debian/RedHat/openEuler/OpenCloudOS/openSUSE）
    if [ -s $File_DebianVersion ]; then
        SYSTEM_FACTIONS="${SYSTEM_DEBIAN}"
    elif [ -s $File_OpenCloudOSRelease ]; then
        # OpenCloudOS 判断优先级需要高于 RedHat，因为8版本基于红帽而9版本不是
        SYSTEM_FACTIONS="${SYSTEM_OPENCLOUDOS}"
    elif [ -s $File_openEulerRelease ]; then
        SYSTEM_FACTIONS="${SYSTEM_OPENEULER}"
    elif [[ "${SYSTEM_NAME}" == *"openSUSE"* ]]; then
        SYSTEM_FACTIONS="${SYSTEM_OPENSUSE}"
    elif [ -f $File_ArchRelease ]; then
        SYSTEM_FACTIONS="${SYSTEM_ARCH}"
    elif [ -s $File_RedHatRelease ]; then
        SYSTEM_FACTIONS="${SYSTEM_REDHAT}"
    else
        Output_Error "无法判断当前运行环境，当前系统不在本脚本的支持范围内"
    fi
    ## 判定系统名称、版本、版本号
    case "${SYSTEM_FACTIONS}" in
    "${SYSTEM_DEBIAN}")
        if [ ! -x /usr/bin/lsb_release ]; then
            apt-get install -y lsb-release
            if [ $? -ne 0 ]; then
                Output_Error "lsb-release 软件包安装失败\n        本脚本需要通过 lsb_release 指令判断系统类型，当前可能为精简安装的系统，因为正常情况下系统会自带该软件包，请自行安装后重新执行脚本！"
            fi
        fi
        SYSTEM_JUDGMENT="$(lsb_release -is)"
        SYSTEM_VERSION_CODENAME="${DEBIAN_CODENAME:-"$(lsb_release -cs)"}"
        ;;
    "${SYSTEM_REDHAT}")
        SYSTEM_JUDGMENT="$(cat $File_RedHatRelease | awk -F ' ' '{printf$1}')"
        ## Red Hat Enterprise Linux
        cat $File_RedHatRelease | grep -q "${SYSTEM_RHEL}"
        [ $? -eq 0 ] && SYSTEM_JUDGMENT="${SYSTEM_RHEL}"
        ## CentOS Stream
        cat $File_RedHatRelease | grep -q "${SYSTEM_CENTOS_STREAM}"
        [ $? -eq 0 ] && SYSTEM_JUDGMENT="${SYSTEM_CENTOS_STREAM}"
        ;;
    "${SYSTEM_OPENCLOUDOS}")
        SYSTEM_JUDGMENT="${SYSTEM_OPENCLOUDOS}"
        ;;
    "${SYSTEM_OPENEULER}")
        SYSTEM_JUDGMENT="${SYSTEM_OPENEULER}"
        ;;
    "${SYSTEM_OPENSUSE}")
        SYSTEM_JUDGMENT="${SYSTEM_OPENSUSE}"
        ;;
    "${SYSTEM_ARCH}")
        SYSTEM_JUDGMENT="${SYSTEM_ARCH}"
        ;;
    esac
    ## 判断系统和其版本是否受本脚本支持
    case "${SYSTEM_JUDGMENT}" in
    "${SYSTEM_DEBIAN}")
        if [[ "${SYSTEM_VERSION_NUMBER:0:1}" != [8-9] && "${SYSTEM_VERSION_NUMBER:0:2}" != 1[0-2] ]]; then
            Output_Error "当前系统版本不在本脚本的支持范围内"
        fi
        ;;
    "${SYSTEM_UBUNTU}")
        if [[ "${SYSTEM_VERSION_NUMBER:0:2}" != 1[4-9] && "${SYSTEM_VERSION_NUMBER:0:2}" != 2[0-3] ]]; then
            Output_Error "当前系统版本不在本脚本的支持范围内"
        fi
        ;;
    "${SYSTEM_RHEL}")
        if [[ "${SYSTEM_VERSION_NUMBER:0:1}" != [7-9] ]]; then
            Output_Error "当前系统版本不在本脚本的支持范围内"
        fi
        ;;
    "${SYSTEM_CENTOS}")
        if [[ "${SYSTEM_VERSION_NUMBER:0:1}" != [7-8] ]]; then
            Output_Error "当前系统版本不在本脚本的支持范围内"
        fi
        ;;
    "${SYSTEM_CENTOS_STREAM}" | "${SYSTEM_ROCKY}" | "${SYSTEM_ALMALINUX}" | "${SYSTEM_OPENCLOUDOS}")
        if [[ "${SYSTEM_VERSION_NUMBER:0:1}" != [8-9] ]]; then
            Output_Error "当前系统版本不在本脚本的支持范围内"
        fi
        ;;
    "${SYSTEM_FEDORA}")
        if [[ "${SYSTEM_VERSION_NUMBER:0:2}" != 3[0-8] ]]; then
            Output_Error "当前系统版本不在本脚本的支持范围内"
        fi
        ;;
    "${SYSTEM_OPENEULER}")
        if [[ "${SYSTEM_VERSION_NUMBER:0:2}" != 2[1-3] ]]; then
            Output_Error "当前系统版本不在本脚本的支持范围内"
        fi
        ;;
    "${SYSTEM_OPENSUSE}")
        if [[ "${SYSTEM_ID}" != "opensuse-leap" && "${SYSTEM_ID}" != "opensuse-tumbleweed" ]]; then
            Output_Error "当前系统版本不在本脚本的支持范围内"
        else
            if [[ "${SYSTEM_ID}" == "opensuse-leap" ]]; then
                if [[ "${SYSTEM_VERSION_NUMBER:0:2}" != 15 ]]; then
                    Output_Error "当前系统版本不在本脚本的支持范围内"
                fi
            fi
        fi
        ;;
    "${SYSTEM_KALI}" | "${SYSTEM_ARCH}")
        # 理论全部支持
        ;;
    *)
        Output_Error "当前系统不在本脚本的支持范围内"
        ;;
    esac
    echo ${SYSTEM_FACTIONS}
}
#Debian系安装脚本
function Debian_family_install_script() {
    #更新源
    apt-get update
    curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
    curl -sL https://deb.nodesource.com/setup_18.x | sudo bash -
    echo "deb https://repo.huaweicloud.com/nodesource/node_18.x stretch main" >> /etc/apt/sources.list
    echo "deb-src https://repo.huaweicloud.com/nodesource/node_18.x stretch main" >> /etc/apt/sources.list
    #安装必要运行库
    apt install apt-transport-https ca-certificates -y
    apt install libgbm-dev -y
    apt install libxkbcommon-x11-0 -y
    apt install libgtk-3-0 -y
    apt install ca-certificates fonts-liberation libappindicator3-1 libasound2 libatk-bridge2.0-0 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 lsb-release wget xdg-utils -y
    apt install libnss3-dev -y
    apt install libxss1 -y
    apt install libasound2 -y
    apt install git -y
    apt install nodejs npm -y
    #克隆 libx264
    git clone https://code.videolan.org/videolan/x264.git x264
    #下载 redis
    wget https://mirrors.huaweicloud.com/redis/redis-7.0.9.tar.gz
    #克隆 ffmpeg
    git clone https://gitee.com/mirrors/ffmpeg.git ffmpeg
    #编译安装 libx264
    cd x264
    ./configure
    make && make install
    cd ..
    #编译安装 redis
    tar -xzvf redis-7.0.9.tar.gz
    cd redis-7.0.9
    make && make install
    cd ..
    #编译安装 ffmpeg
    cd ffmpeg
    ./configure --enable-shared --enable-swscale --enable-gpl --enable-nonfree --enable-pic --prefix=/home/ffmpeg --enable-version3 --enable-postproc --enable-pthreads --enable-static --enable-libx264 --disable-x86asm
    make && make install
    cd ..
    #克隆 Miao-Yunzai
    git clone --depth=1 https://gitee.com/yoimiya-kokomi/Miao-Yunzai.git
    cd Miao-Yunzai
    #克隆 Miao-Yunzai 插件
    git clone --depth=1 https://gitee.com/yoimiya-kokomi/miao-plugin.git ./plugins/miao-plugin/
    #安装 pnpm
    npm --registry=https://registry.npmmirror.com install pnpm -g
    #设置 node.js插件源为国内源
    pnpm config set registry https://registry.npmmirror.com
    #安装 node.js插件
    pnpm install -P
    #安装 puppeteer chromium
    node node_modules/puppeteer/install.js
    #启动 redis
    redis-server --save 900 1 --save 300 10 --daemonize yes --ignore-warnings ARM64-COW-BUG
}
#RHEL系安装脚本
function RHEL_family_install_script() {
    curl -sL https://rpm.nodesource.com/setup_18.x | bash -

    yum -y update
    yum install pango.x86_64 libXcomposite.x86_64 libXcursor.x86_64 libXdamage.x86_64 libXext.x86_64 libXi.x86_64 libXtst.x86_64 cups-libs.x86_64 libXScrnSaver.x86_64 libXrandr.x86_64 GConf2.x86_64 alsa-lib.x86_64 atk.x86_64 gtk3.x86_64 -y
    yum install yum-utils -y
    yum install git -y
    yum install wget -y
    yum install gcc gcc-c++ -y
    yum install make -y
    yum install curl -y
    yum install nodejs npm -y

    wget http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
    tar xf yasm-1.3.0.tar.gz
    cd yasm-1.3.0/
    ./configure --prefix=/usr/local
    make -j12 && make install
    cd ..
    git clone https://code.videolan.org/videolan/x264.git x264
    wget https://mirrors.huaweicloud.com/redis/redis-7.0.9.tar.gz
    git clone https://gitee.com/mirrors/ffmpeg.git ffmpeg
    cd x264
    ./configure --disable-asm
    make && make install
    cd ..
    tar -xzvf redis-7.0.9.tar.gz
    cd redis-7.0.9
    make && make install
    cd ..
    cd ffmpeg
    ./configure
    make && make install
    cd ..
    git clone --depth=1 https://gitee.com/yoimiya-kokomi/Miao-Yunzai.git
    cd Miao-Yunzai
    git clone --depth=1 https://gitee.com/yoimiya-kokomi/miao-plugin.git ./plugins/miao-plugin/
    npm --registry=https://registry.npmmirror.com install pnpm -g
    pnpm config set registry https://registry.npmmirror.com
    pnpm install -P
    node node_modules/puppeteer/install.js
    redis-server --save 900 1 --save 300 10 --daemonize yes --ignore-warnings ARM64-COW-BUG
}
#RHEL家族
function RHEL_famliy() {
    case "${SYSTEM_FACTIONS}" in 
    "${SYSTEM_OPENSUSE}")
        RHEL_family_install_script
        ;;
    "${SYSTEM_OPENCLOUDOS}")
        RHEL_family_install_script
        ;;
    "${SYSTEM_OPENEULER}")
        RHEL_family_install_script
        ;;
    "${SYSTEM_FEDORA}")
        RHEL_family_install_script
        ;;
    "${SYSTEM_ALMALINUX}")
        RHEL_family_install_script
        ;;
    "${SYSTEM_ROCKY}")
        RHEL_family_install_script
        ;;
    "${SYSTEM_CENTOS_STREAM}")
        RHEL_family_install_script
        ;;
    "${SYSTEM_CENTOS}")
        RHEL_family_install_script
        ;;
    "${SYSTEM_RHEL}")
        RHEL_family_install_script
        ;;
    "${SYSTEM_REDHAT}")
        RHEL_family_install_script
        ;;
    esac
}
#debian家族
function Debian_family() {
    case "${SYSTEM_FACTIONS}" in
    "${SYSTEM_UBUNTU}")
        Debian_family_install_script
        ;;
    "${SYSTEM_DEBIAN}")
        Debian_family_install_script
        ;;
    "${SYSTEM_KALI}")
        Debian_family_install_script
        ;;
    esac
}
function output(){
    RHEL_family
    Debian_family
}
## 组合函数
function Combin_Function() {
    PermissionJudgment
    EnvJudgment
    output
}
#运行主程序
Combin_Function
