FROM centos:7

ADD setup /setup

RUN \
  rpm --import http://mirror.centos.org/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-7 && \
  rpm --import http://mirror.centos.org/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-Testing-7 && \
  yum clean all && \
  yum --enablerepo=centosplus install -y deltarpm redhat-lsb

ENV PATH="/opt/puppetlabs/bin:${PATH}"

# Install utils
RUN yum install -y wget git tar nc hostname jq cronie

# Install Puppet
RUN rpm -Uvh https://yum.puppetlabs.com/puppet5/el/7/x86_64/puppet5-release-5.0.0-6.el7.noarch.rpm && \
  yum install -y puppet

RUN puppet --version

# Install Puppet modules
RUN puppet module install puppet-epel && \
    puppet module install puppet-fetchcrl && \
    puppet module install puppet-python && \
    puppet module install cnafsd-testvos && \
    puppet module install cnafsd-testca && \
    puppet module install cnafsd-umd4 && \
    puppet module install cnafsd-storm

RUN sh /setup/setup.sh

USER tester
WORKDIR /home/tester

VOLUME /assets