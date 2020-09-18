include epel
include umd4
include testvos
include testca

class { 'storm::repo':
  enabled     => ['stable'],
}

$packages = [
  'openldap-clients',
  'globus-gass-copy-progs',
  'gfal2-util',
  'gfal2-all',
  'dcache-srmclient',
  'storm-srm-client',
  'davix',
  'myproxy',
]

package { $packages:
  ensure => 'latest',
}

package { 'voms-clients':
  ensure => 'installed',
  source => 'https://ci.cloud.cnaf.infn.it/view/voms/job/pkg.voms/job/release_sep_19/lastSuccessfulBuild/artifact/repo/centos6/voms-clients3-3.3.1-0.el6.centos.noarch.rpm',
}

include python

package { 'robotframework':
  ensure   => installed,
  require  => Package['pip'],
  provider => 'pip',
}
package { 'robotframework-httplibrary':
  ensure   => installed,
  require  => [Package['pip'], Package['robotframework']],
  provider => 'pip',
}


Class['epel']
-> Class['umd4']
-> Class['python']
-> Class['storm::repo']
-> Class['storm::testvos']
-> Class['storm::testca']
-> Package[$packages]
-> Package['voms-clients']
-> Package['robotframework']
