
Install_modsecurity() {
  if [ -d "${modsecurity_install_dir}" ]; then
      echo "${CWARNING}modsecurity already installed! ${CEND}"
  else
    pushd ${oneinstack_dir}/src > /dev/null
    tar xzf modsecurity-${modsecurity_ver}.tar.gz
    pushd modsecurity-${modsecurity_ver} > /dev/null
    sh autogen.sh
    ./configure --prefix=${modsecurity_install_dir} 
    make -j ${THREAD} && make install
    popd > /dev/null
    rm -rf modsecurity-${modsecurity_ver}
    popd > /dev/null
  fi
}
