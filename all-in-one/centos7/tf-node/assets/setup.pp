include ntp
include epel
include umd4
include fetchcrl
include testvos
include testca
include sd_users

include storm::users
include lcmaps

package { 'attr':
  ensure => latest,
}

file { '/storage':
  ensure  => directory,
  mode    => '0755',
  owner   => 'root',
  group   => 'root',
  recurse => false,
} -> class { 'storm::storage':
  root_directories => [
    '/storage/test.vo',
    '/storage/test.vo.2',
    '/storage/igi',
    '/storage/noauth',
    '/storage/test.vo.bis',
    '/storage/nested',
    '/storage/tape',
    '/storage/info',
  ],
}

exec { 'apply-fixtures':
  command     => '/bin/bash /assets/service/fixture.sh',
}

class { 'bdii':
  firewall   => false,
  bdiipasswd => 'supersecretpassword',
}

Class['storm::users']
-> Class['lcmaps']

Class['storm::storage']
-> Exec['apply-fixtures']
