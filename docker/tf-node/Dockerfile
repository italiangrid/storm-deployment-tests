FROM centos/systemd

RUN \
  rpm --import http://mirror.centos.org/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-7 && \
  rpm --import http://mirror.centos.org/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-Testing-7 && \
  rpm -Uvh https://yum.puppetlabs.com/puppet5/el/7/x86_64/puppet5-release-5.0.0-6.el7.noarch.rpm && \
  yum clean all && \
  yum -y update && \
  yum --enablerepo=centosplus install -y epel-release redhat-lsb wget git tar puppet

ENV PATH="/opt/puppetlabs/bin:${PATH}"

ADD setup /setup
RUN sh /setup/setup.sh

ENTRYPOINT /usr/sbin/init