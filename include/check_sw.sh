#!/bin/bash
# Author:  Alpha Eva <kaneawk AT gmail.com>




installDepsRHEL() {
  [ -e '/etc/yum.conf' ] && sed -i 's@^exclude@#exclude@' /etc/yum.conf
  # Uninstall the conflicting packages
  echo "${CMSG}Removing the conflicting packages...${CEND}"
  if [ "${RHEL_ver}" == '8' ]; then
    ARCH=$( /bin/arch )
    dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    if [[ "$(lsb_release -is)" =~ "RedHat" ]]; then
      subscription-manager repos --enable codeready-builder-for-rhel-8-${ARCH}-rpms
      dnf -y install chrony oniguruma-devel rpcgen
    elif [[ "$(lsb_release -is)" =~ "Oracle" ]]; then
      dnf config-manager --set-enabled ol8_codeready_builder
      dnf -y install chrony oniguruma-devel rpcgen
    elif grep -qw "^\[PowerTools\]" /etc/yum.repos.d/*.repo; then
      dnf -y --enablerepo=PowerTools install chrony oniguruma-devel rpcgen
    else
      dnf -y --enablerepo=powertools install chrony oniguruma-devel rpcgen
    fi
    systemctl enable chronyd
    systemctl stop firewalld && systemctl mask firewalld.service
  elif [ "${RHEL_ver}" == '7' ]; then
    yum -y install epel-release
    yum -y groupremove "Basic Web Server" "MySQL Database server" "MySQL Database client"
    systemctl stop firewalld && systemctl mask firewalld.service
  elif [ "${RHEL_ver}" == '6' ]; then
    yum -y groupremove "FTP Server" "PostgreSQL Database client" "PostgreSQL Database server" "MySQL Database server" "MySQL Database client" "Web Server"
  fi

  if [ ${RHEL_ver} -ge 7 >/dev/null 2>&1 ] && [ "${iptables_flag}" == 'y' ]; then
    yum -y install iptables-services
    systemctl enable iptables.service
    systemctl enable ip6tables.service
  fi

  echo "${CMSG}Installing dependencies packages...${CEND}"
  # Install needed packages
  pkgList="deltarpm drpm gcc gcc-c++ make cmake autoconf libjpeg libjpeg-devel libjpeg-turbo libjpeg-turbo-devel libpng libpng-devel libxml2 libxml2-devel zlib zlib-devel libzip libzip-devel glibc glibc-devel krb5-devel libc-client libc-client-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel libaio numactl numactl-libs readline-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel net-tools libxslt-devel libicu-devel libevent-devel libtool libtool-ltdl bison gd-devel vim-enhanced pcre-devel libmcrypt libmcrypt-devel mhash mhash-devel mcrypt zip unzip ntpdate sqlite-devel sysstat patch bc expect expat-devel oniguruma oniguruma-devel libtirpc-devel nss libnsl rsync rsyslog git lsof lrzsz psmisc wget which libatomic tmux"
  for Package in ${pkgList}; do
    yum -y install ${Package}
  done
  [ ${RHEL_ver} -lt 8 >/dev/null 2>&1 ] && yum -y install cmake3

  yum -y update bash openssl glibc
}



installDepsBySrc() {
  pushd ${oneinstack_dir}/src > /dev/null
  if [ "${LikeOS}" == 'RHEL' ] && [ "${RHEL_ver}" == '6' ]; then
    # upgrade autoconf for RHEL6
    rpm -Uvh autoconf-2.69-12.2.noarch.rpm
  fi

  if ! command -v icu-config > /dev/null 2>&1 || icu-config --version | grep '^3.' || [ "${Ubuntu_ver}" == "20" ]; then
    tar xzf icu4c-${icu4c_ver}_${icu4c_ver2}-src.tgz
    pushd icu/source > /dev/null
    ./configure --prefix=/usr/local
    make -j ${THREAD} && make install
    popd > /dev/null
    rm -rf icu
  fi

  if command -v lsof >/dev/null 2>&1; then
    echo 'already initialize' > ~/.oneinstack
  else
    echo "${CFAILURE}${PM} config error parsing file failed${CEND}"
    kill -9 $$; exit 1;
  fi

  popd > /dev/null
}
