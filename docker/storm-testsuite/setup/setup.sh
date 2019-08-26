#!/bin/bash

gpg --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

yum clean all
yum update -y

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
puppet apply --modulepath=/ci-puppet-modules/modules:/etc/puppet/modules/ --detailed-exitcodes /setup/manifest.pp

# check if errors occurred after puppet apply:
if [[ ( $? -eq 4 ) || ( $? -eq 6 ) ]]; then
  exit 1
fi

# install StoRM stable repo EL7
yum-config-manager --add-repo https://repo.cloud.cnaf.infn.it/repository/storm/stable/storm-stable-centos7.repo

yum install -y storm-srm-client davix

# install utilities
yum install -y nc

pip install --upgrade robotframework-httplibrary

# install clients
yum install -y myproxy

yum localinstall -y https://ci.cloud.cnaf.infn.it/view/voms/job/pkg.voms/job/release_dec_17/lastSuccessfulBuild/artifact/repo/centos6/voms-clients3-3.3.1-0.el6.centos.noarch.rpm

echo 'export X509_USER_PROXY="/tmp/x509up_u$(id -u)"'>/etc/profile.d/x509_user_proxy.sh

# Add tester user
adduser -d /home/tester tester

# .globus
mkdir /home/tester/.globus
chown tester:tester /home/tester/.globus

# setup voms-fake
mkdir /home/tester/voms-fake
cp -R /setup/voms-fake /home/tester
chown tester:tester /home/tester/voms-fake/*.pem
chmod 644 /home/tester/voms-fake/voms_example.cert.pem
chmod 400 /home/tester/voms-fake/voms_example.key.pem