#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>

Install_Python() {
  if [ -e "${python_install_dir}/bin/python" ]; then
    echo "${CWARNING}Python already installed! ${CEND}"
  else
    pushd ${oneinstack_dir}/src > /dev/null

    if [ "${PM}" == 'yum' ]; then
      [ -z "`grep -w epel /etc/yum.repos.d/*.repo`" ] && yum -y install epel-release
      pkgList="gcc dialog augeas-libs openssl openssl-devel libffi-devel redhat-rpm-config ca-certificates"
      for Package in ${pkgList}; do
        yum -y install ${Package}
      done
    elif [ "${PM}" == 'apt-get' ]; then
      pkgList="gcc dialog libaugeas0 augeas-lenses libssl-dev libffi-dev ca-certificates"
      for Package in ${pkgList}; do
        apt-get -y install $Package
      done
    fi

    # Install Python3
    if [ ! -e "${python_install_dir}/bin/python" -a ! -e "${python_install_dir}/bin/python3" ] ;then
      src_url=https://www.python.org/ftp/python/${python_ver}/Python-${python_ver}.tgz && Download_src
      tar xzf Python-${python_ver}.tgz
      pushd Python-${python_ver} > /dev/null
      ./configure --prefix=${python_install_dir}
      make && make install
      [ ! -e "${python_install_dir}/bin/python" -a -e "${python_install_dir}/bin/python3" ] && ln -s ${python_install_dir}/bin/python{3,}
      [ ! -e "${python_install_dir}/bin/pip" -a -e "${python_install_dir}/bin/pip3" ] && ln -s ${python_install_dir}/bin/pip{3,}
      popd > /dev/null
    fi

    if [ ! -e "${python_install_dir}/bin/pip" ]; then
      src_url=https://github.com/pypa/setuptools/archive/refs/tags/v${setuptools_ver}.zip && Download_src
      src_url=https://github.com/pypa/pip/archive/refs/tags/${pip_ver}.tar.gz && Download_src
      unzip -q setuptools-${setuptools_ver}.zip
      tar xzf pip-${pip_ver}.tar.gz
      pushd setuptools-${setuptools_ver} > /dev/null
      ${python_install_dir}/bin/python setup.py install
      popd > /dev/null
      pushd pip-${pip_ver} > /dev/null
      ${python_install_dir}/bin/python setup.py install
      popd > /dev/null
    fi


    if [ -e "${python_install_dir}/bin/python3" ]; then
      echo "${CSUCCESS}Python ${python_ver} installed successfully! ${CEND}"
      rm -rf Python-${python_ver}
    fi
    popd > /dev/null
  fi
}

Uninstall_Python() {
  if [ -e "${python_install_dir}/bin/python" ]; then
    echo "${CMSG}Python uninstall completed${CEND}"
    rm -rf ${python_install_dir}
  fi
}
