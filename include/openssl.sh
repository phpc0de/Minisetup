#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>


Install_openSSL() {
  if [ -e "${openssl_install_dir}/lib/libssl.a" ]; then
    echo "${CWARNING}openSSL already installed! ${CEND}"
  else
    pushd ${oneinstack_dir}/src > /dev/null  
    tar xzf openssl-${openssl_ver}.tar.gz

    pushd openssl-${openssl_ver} > /dev/null
    make clean
    ./config -Wl,-rpath=${openssl_install_dir}/lib -fPIC --prefix=${openssl_install_dir} --openssldir=${openssl_install_dir}
    make depend
    make -j ${THREAD} && make install
    popd > /dev/null
    if [ -f "${openssl_install_dir}/lib/libcrypto.a" ]; then
      echo "${CSUCCESS}openSSL installed successfully! ${CEND}"
      /bin/cp cacert.pem ${openssl_install_dir}/cert.pem
      rm -rf openssl-${openssl_ver}
      ln -s ${openssl_install_dir}/lib/libssl.so.1.1 /usr/lib/libssl.so.1.1
      ln -s ${openssl_install_dir}/lib/libcrypto.so.1.1 /usr/lib/libcrypto.so.1.1
    else
      echo "${CFAILURE}openSSL install failed, Please contact the author! ${CEND}" && lsb_release -a
      kill -9 $$; exit 1;
    fi
    popd > /dev/null
  fi
}
