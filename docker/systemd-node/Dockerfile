FROM centos/systemd

RUN \
  rpm --import http://mirror.centos.org/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-7 && \
  rpm --import http://mirror.centos.org/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-Testing-7 && \
  yum clean all && \
  yum -y update && \
  yum --enablerepo=centosplus install -y epel-release redhat-lsb wget git tar

ENV PATH="/opt/puppetlabs/bin:${PATH}"

ENTRYPOINT /usr/sbin/init