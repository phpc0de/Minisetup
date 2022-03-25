
Install_modsecurity() {
  if [ -d "${modsecurity_install_dir}" ]; then
      echo "${CWARNING}modsecurity already installed! ${CEND}"
  else
    make clean all
    pushd ${oneinstack_dir}/src > /dev/null
    #tar xzf "modsecurity-"${modsecurity_ver}.tar.gz
    #tar xzf "modsecurity-nginx-v"${modsecurity_nginx_ver}.tar.gz
    pushd "ModSecurity" > /dev/null
    git submodule init
    git submodule update
    sh ./build.sh
    ./configure --prefix=${modsecurity_install_dir} 
    make -j ${THREAD} && make install
    popd > /dev/null
    #rm -rf "modsecurity-"${modsecurity_ver}
    popd > /dev/null
  fi
}
