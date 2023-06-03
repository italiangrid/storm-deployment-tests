FROM italiangrid/systemd-node

ARG PUPPET_STDLIB_VERSION=8.6.0
ARG PUPPET_FETCHCRL_VERSION=5.1.0
ARG PUPPET_EPEL_VERSION=4.1.0
ARG PUPPET_APT_VERSION=8.5.0
ARG PUPPET_FIREWALL_VERSION=5.0.0
ARG PUPPET_SAZSUDO_VERSION=7.0.2
ARG PUPPET_MYSQL_VERSION=14.0.0
ARG PUPPET_ACCOUNTS_VERSION=8.0.0

RUN puppet module install puppetlabs-stdlib --version $PUPPET_STDLIB_VERSION
RUN puppet module install puppetlabs-apt --version $PUPPET_APT_VERSION
RUN puppet module install puppet-fetchcrl --version $PUPPET_FETCHCRL_VERSION
RUN puppet module install puppet-epel --version $PUPPET_EPEL_VERSION
RUN puppet module install puppetlabs-firewall --version $PUPPET_FIREWALL_VERSION
RUN puppet module install saz-sudo --version $PUPPET_SAZSUDO_VERSION
RUN puppet module install puppetlabs-mysql --version $PUPPET_MYSQL_VERSION
RUN puppet module install puppetlabs-accounts --version $PUPPET_ACCOUNTS_VERSION

RUN puppet module install cnafsd-bdii
RUN puppet module install cnafsd-umd4
RUN puppet module install cnafsd-voms
RUN puppet module install cnafsd-testca
RUN puppet module install cnafsd-sdds_users

RUN puppet module install cnafsd-storm
RUN puppet module install cnafsd-lcmaps

ENV container=docker

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]