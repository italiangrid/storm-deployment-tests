#!/bin/bash

# Start by making sure your system is up-to-date:
yum update -y
# Compilers and related tools:
yum groupinstall -y "development tools"
# Libraries needed during compilation to enable all features of Python:
yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel expat-devel
# If you are on a clean "minimal" install of CentOS you also need the wget tool:
yum install -y wget

# Python 2.7.14:
wget http://python.org/ftp/python/2.7.14/Python-2.7.14.tar.xz
tar xf Python-2.7.14.tar.xz
cd Python-2.7.14
./configure --prefix=/usr/local --enable-unicode=ucs4 --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"
make && make altinstall

# Strip the Python 2.7 binary:
strip /usr/local/lib/libpython2.7.so.1.0

# First get the script:
wget https://bootstrap.pypa.io/get-pip.py

# Then execute it using Python 2.7 and/or Python 3.6:
python2.7 get-pip.py

# install the list of puppet modules after downloading from github
git clone git://github.com/cnaf/ci-puppet-modules.git /ci-puppet-modules

# install all puppet modules required by the StoRM testsuite.
# the "--detailed-exitcodes" flag returns explicit exit status:
# exit code '2' means there were changes
# exit code '4' means there were failures during the transaction
# exit code '6' means there were both changes and failures
puppet apply --modulepath=/ci-puppet-modules/modules:/etc/puppet/modules/ --detailed-exitcodes /manifest.pp

# check if errors occurred after puppet apply:
if [[ ( $? -eq 4 ) || ( $? -eq 6 ) ]]; then
  exit 1
fi

# install utilities
yum install -y fetch-crl nc

# run fetch-crl
fetch-crl

# check if errors occurred after fetch-crl execution
if [ $? != 0 ]; then
  exit 1
fi

pip2.7 install --upgrade robotframework-httplibrary

# install clients
yum install -y myproxy

# install gfal
yum install -y gfal2-util gfal2-all

yum localinstall -y https://ci.cloud.cnaf.infn.it/view/voms/job/pkg.voms/job/release_dec_17/lastSuccessfulBuild/artifact/repo/centos6/voms-clients3-3.3.1-0.el6.centos.noarch.rpm

echo 'export X509_USER_PROXY="/tmp/x509up_u$(id -u)"'>/etc/profile.d/x509_user_proxy.sh
