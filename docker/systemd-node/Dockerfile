FROM centos:7

# cURL bug: https://bugs.centos.org/view.php?id=16282
RUN touch /etc/sysconfig/64bit_strstr_via_64bit_strstr_sse2_unaligned

RUN echo "include_only=.garr.it,.cern.ch" >> /etc/yum/pluginconf.d/fastestmirror.conf && \
  yum -y install hostname which wget git tar nc deltarpm redhat-lsb sudo file less epel-release && \
  yum -y update && \
  yum clean all && \
  rm -rf /var/cache/yum && \
  (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do \
  [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
  rm -f /lib/systemd/system/multi-user.target.wants/*; \
  rm -f /etc/systemd/system/*.wants/*; \
  rm -f /lib/systemd/system/local-fs.target.wants/*; \
  rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
  rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
  rm -f /lib/systemd/system/basic.target.wants/*; \
  rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install Puppet
RUN rpm -Uvh https://yum.puppetlabs.com/puppet5/el/7/x86_64/puppet5-release-5.0.0-6.el7.noarch.rpm && \
  wget https://yum.puppetlabs.com/RPM-GPG-KEY-puppet-20250406 && \
  rpm --import RPM-GPG-KEY-puppet-20250406 && \
  yum install -y puppet

ENV PATH="/opt/puppetlabs/bin:${PATH}"
ENV container=docker

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]