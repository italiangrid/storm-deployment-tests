FROM centos/systemd

RUN \
  rpm --import http://mirror.centos.org/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-7 && \
  rpm --import http://mirror.centos.org/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-Testing-7 && \
  yum clean all && \
  yum -y update && \
  yum --enablerepo=centosplus install -y redhat-lsb

ENV PATH="/opt/puppetlabs/bin:${PATH}"

# Install utils
RUN yum install -y wget git tar nc deltarpm

# Install Puppet
RUN rpm -Uvh https://yum.puppetlabs.com/puppet5/el/7/x86_64/puppet5-release-5.0.0-6.el7.noarch.rpm && \
  yum install -y puppet

# Install EPEL repositories:
RUN yum install -y epel-release

# Install UMD repositories:
RUN yum localinstall -y http://repository.egi.eu/sw/production/umd/4/centos7/x86_64/updates/umd-release-4.1.3-1.el7.centos.noarch.rpm

ENTRYPOINT /usr/sbin/init
