#!/bin/bash

gpg --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

yum clean all

# install GPG keys
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*

# install EPEL
yum --enablerepo=extras install epel-release -y

# install utils
yum install -y redhat-lsb hostname git wget tar jq

# install davix
yum install -y davix

# install puppet
rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
yum install -y puppet
puppet module install puppetlabs-stdlib

# install the list of puppet modules after downloading from github
git clone git://github.com/cnaf/ci-puppet-modules.git /ci-puppet-modules

# install all puppet modules required by the StoRM testsuite.
# the "--detailed-exitcodes" flag returns explicit exit status:
# exit code '2' means there were changes
# exit code '4' means there were failures during the transaction
# exit code '6' means there were both changes and failures
puppet apply --modulepath=/ci-puppet-modules/modules:/etc/puppet/modules/ --detailed-exitcodes /manifest.pp

# install python enum
wget https://files.pythonhosted.org/packages/c5/db/e56e6b4bbac7c4a06de1c50de6fe1ef3810018ae11732a50f15f62c7d050/enum34-1.1.6-py2-none-any.whl
pip install enum34-1.1.6-py2-none-any.whl

# install StoRM stable repo EL7
yum-config-manager --add-repo https://repo.cloud.cnaf.infn.it/repository/storm/stable/storm-stable-centos7.repo

yum install -y storm-srm-client

# check if errors occurred after puppet apply:
if [[ ( $? -eq 4 ) || ( $? -eq 6 ) ]]; then
  exit 1
fi

yum update -y

# install utilities
yum install -y fetch-crl nc

# run fetch-crl
fetch-crl

# check if errors occurred after fetch-crl execution
if [ $? != 0 ]; then
  exit 1
fi

pip install --upgrade robotframework-httplibrary

# install clients
yum install -y myproxy

yum localinstall -y https://ci.cloud.cnaf.infn.it/view/voms/job/pkg.voms/job/release_dec_17/lastSuccessfulBuild/artifact/repo/centos6/voms-clients3-3.3.1-0.el6.centos.noarch.rpm

echo 'export X509_USER_PROXY="/tmp/x509up_u$(id -u)"'>/etc/profile.d/x509_user_proxy.sh
