yumrepo { 'voms-rpm-nightly':
  ensure   => present,
  descr    => 'voms-rpm-nightly',
  baseurl  => 'https://repo.cloud.cnaf.infn.it/repository/voms-rpm-nightly/centos7/',
  enabled  => 1,
  protect  => 1,
  priority => 1,
  gpgcheck => 0,
}

yumrepo { 'voms-rpm-stable':
  ensure   => present,
  descr    => 'voms-rpm-stable',
  baseurl  => 'https://repo.cloud.cnaf.infn.it/repository/voms-rpm-stable/centos7/',
  enabled  => 1,
  protect  => 1,
  priority => 1,
  gpgcheck => 0,
}