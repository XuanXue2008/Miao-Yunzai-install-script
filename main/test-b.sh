
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


function RHEL_home() {
    if [[ "${SYSTEM_FACTIONS}" == "${SYSTEM_REDHAT}" ]]; then
    echo REDHAT
    elif [[ "${SYSTEM_FACTIONS}" == "${SYSTEM_RHEL}" ]]; then
    echo 'Red Hat Enterprise Linux'
    elif [[ "${SYSTEM_FACTIONS}" == "${SYSTEM_CENTOS}" ]]; then
    echo CENTOS
    elif [[ "${SYSTEM_FACTIONS}" == "${SYSTEM_CENTOS_STREAM}" ]]; then
    echo CENTOS_STREAM
    elif [[ "${SYSTEM_FACTIONS}" == "${SYSTEM_ROCKY}" ]]; then
    echo ROCKY
    elif [[ "${SYSTEM_FACTIONS}" == "${SYSTEM_ALMALINUX}" ]]; then
    echo ALMALINUX
    elif [[ "${SYSTEM_FACTIONS}" == "${SYSTEM_FEDORA}" ]]; then
    echo FEDORA
    elif [[ "${SYSTEM_FACTIONS}" == "${SYSTEM_OPENEULER}" ]]; then
    echo OPENEULE
    elif [[ "${SYSTEM_FACTIONS}" == "${SYSTEM_OPENCLOUDOS}" ]]; then
    echo OPENCLOUDOS
    elif [[ "${SYSTEM_FACTIONS}" == "${SYSTEM_OPENSUSE}" ]]; then
    echo OPENSUSE
    fi
}

function Debian_home() {
    if [[ "${SYSTEM_FACTIONS}" == "${SYSTEM_UBUNTU}" ]]; then
    echo Ubuntu
    elif [[ "${SYSTEM_FACTIONS}" == "${SYSTEM_DEBIAN}" ]]; then
    echo Debian
    elif [[ "${SYSTEM_FACTIONS}" == "${SYSTEM_KALI}" ]]; then
    echo Kail
    fi
}

function output(){
    RHEL_home
    Debian_home
}

## 组合函数
function Combin_Function() {
    PermissionJudgment
    EnvJudgment
    output
}

Combin_Function
