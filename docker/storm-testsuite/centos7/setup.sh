#!/bin/bash

gpg --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

yum clean all

# install GPG keys
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*

# install EPEL
yum --enablerepo=extras install epel-release -y

# install utils
yum install -y redhat-lsb hostname git wget tar

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

stormClientRpmUrl="https://ci.cloud.cnaf.infn.it/view/storm/job/pkg.storm/job/cdmi_el7/lastSuccessfulBuild/artifact/rpms/centos7/storm-srm-client-1.6.1-1.el7.x86_64.rpm"

yum install -y ${stormClientRpmUrl}

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

pip install --upgrade robotframework-httplibrary

# install clients
yum install -y myproxy

yum localinstall -y https://ci.cloud.cnaf.infn.it/view/voms/job/pkg.voms/job/release_dec_17/lastSuccessfulBuild/artifact/repo/centos6/voms-clients3-3.3.1-0.el6.centos.noarch.rpm

echo 'export X509_USER_PROXY="/tmp/x509up_u$(id -u)"'>/etc/profile.d/x509_user_proxy.sh
