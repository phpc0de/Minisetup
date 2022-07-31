#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>

if [ -e "/usr/bin/yum" ]; then
  PM=yum
  if [ -e /etc/yum.repos.d/CentOS-Base.repo ] && grep -Eqi "release 6." /etc/redhat-release; then
    sed -i "s@centos/\$releasever@centos-vault/6.10@g" /etc/yum.repos.d/CentOS-Base.repo
    sed -i 's@centos/RPM-GPG@centos-vault/RPM-GPG@g' /etc/yum.repos.d/CentOS-Base.repo
    [ -e /etc/yum.repos.d/epel.repo ] && rm -f /etc/yum.repos.d/epel.repo
  fi
  if ! command -v lsb_release >/dev/null 2>&1; then

    yum -y install redhat-lsb-core
    clear
  fi
fi

if [ -e "/usr/bin/apt-get" ]; then
  PM=apt-get
  command -v lsb_release >/dev/null 2>&1 || { apt-get -y update > /dev/null; apt-get -y install lsb-release; clear; }
fi

command -v lsb_release >/dev/null 2>&1 || { echo "${CFAILURE}${PM} source failed! ${CEND}"; kill -9 $$; exit 1; }

# Get OS Version
OS=$(lsb_release -is)
if [[ "${OS}" =~ ^CentOS$|^CentOSStream$|^RedHat$|^Rocky$|^AlmaLinux$|^Fedora$|^Amazon$|^AlibabaCloud$|^AlibabaCloud\(AliyunLinux\)$|^AnolisOS$|^EulerOS$|^openEuler$|^Oracle$ ]]; then
  LikeOS=RHEL
  RHEL_ver=$(lsb_release -rs | awk -F. '{print $1}' | awk '{print $1}')
  [[ "${OS}" =~ ^Fedora$ ]] && [ ${RHEL_ver} -ge 19 >/dev/null 2>&1 ] && { RHEL_ver=7; Fedora_ver=$(lsb_release -rs); }
fi

# Check OS Version
if [ ${RHEL_ver} -lt 6 >/dev/null 2>&1 ] || [ ${Debian_ver} -lt 8 >/dev/null 2>&1 ] || [ ${Ubuntu_ver} -lt 16 >/dev/null 2>&1 ]; then
  echo "${CFAILURE}Does not support this OS, Please install CentOS 6+,Debian 8+,Ubuntu 16+ ${CEND}"
  kill -9 $$; exit 1;
fi

command -v gcc > /dev/null 2>&1 || $PM -y install gcc
gcc_ver=$(gcc -dumpversion | awk -F. '{print $1}')

[ ${gcc_ver} -lt 5 >/dev/null 2>&1 ] && sudo yum install -y devtoolset-8-gcc devtoolset-8-gcc-c++ &&  source scl_source enable devtoolset-9 && scl enable devtoolset-9 -- bash

if uname -m | grep -Eqi "arm|aarch64"; then
  armplatform="y"
  if uname -m | grep -Eqi "armv7"; then
    TARGET_ARCH="armv7"
  elif uname -m | grep -Eqi "armv8"; then
    TARGET_ARCH="arm64"
  elif uname -m | grep -Eqi "aarch64"; then
    TARGET_ARCH="aarch64"
  else
    TARGET_ARCH="unknown"
  fi
fi

if [ "$(uname -r | awk -F- '{print $3}' 2>/dev/null)" == "Microsoft" ]; then
  Wsl=true
fi

if [ "$(getconf WORD_BIT)" == "32" ] && [ "$(getconf LONG_BIT)" == "64" ]; then
  OS_BIT=64
  SYS_BIT_j=x64 #jdk
  SYS_BIT_a=x86_64 #mariadb
  SYS_BIT_b=x86_64 #mariadb
  SYS_BIT_c=x86_64 #ZendGuardLoader
  SYS_BIT_d=x86-64 #ioncube
  SYS_BIT_n=x64 #nodejs
  [ "${TARGET_ARCH}" == 'aarch64' ] && { SYS_BIT_j=aarch64; SYS_BIT_c=aarch64; SYS_BIT_d=aarch64; SYS_BIT_n=arm64; }
else
  OS_BIT=32
  SYS_BIT_j=i586
  SYS_BIT_a=x86
  SYS_BIT_b=i686
  SYS_BIT_c=i386
  SYS_BIT_d=x86
  SYS_BIT_n=x86
  [ "${TARGET_ARCH}" == 'armv7' ] && { SYS_BIT_j=arm32-vfp-hflt; SYS_BIT_c=armhf; SYS_BIT_d=armv7l; SYS_BIT_n=armv7l; }
fi

THREAD=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)

if [ ${Debian_ver} -lt 9 >/dev/null 2>&1 ]; then
  sslLibVer=ssl100
elif [[ "${RHEL_ver}" =~ ^[6-7]$ ]] && [ "${OS}" != 'Fedora' ]; then
  sslLibVer=ssl101
elif [ ${Debian_ver} -ge 9 >/dev/null 2>&1 ] || [ ${Ubuntu_ver} -ge 16 >/dev/null 2>&1 ]; then
  sslLibVer=ssl102
elif [ ${Fedora_ver} -ge 27 >/dev/null 2>&1 ]; then
  sslLibVer=ssl102
elif [ "${RHEL_ver}" == '8' ]; then
  sslLibVer=ssl1:111
else
  sslLibVer=unknown
fi
