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

$storage_area_root_directories = [
  '/storage/test.vo',
  '/storage/test.vo.2',
  '/storage/igi',
  '/storage/noauth',
  '/storage/test.vo.bis',
  '/storage/nested',
  '/storage/tape',
  '/storage/info'
]

storm::rootdir { '/storage': }
storm::sarootdir { $storage_area_root_directories: }

exec { 'apply-fixtures':
  command => '/bin/bash /assets/node/fixture.sh',
}

class { 'bdii':
  firewall   => false,
  bdiipasswd => 'supersecretpassword',
}

Class['storm::users']
-> Class['lcmaps']

Storm::Sarootdir[$storage_area_root_directories]
-> Exec['apply-fixtures']
