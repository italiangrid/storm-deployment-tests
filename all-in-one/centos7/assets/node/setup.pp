# repositories
include epel
include umd4

# CAs
include fetchcrl
include testca

# SDDS users
include sdds_users::sd_users

# VOs
include voms::dteam
include voms::testvo
include voms::testvo2

# StoRM users
include storm::users

# LCMAPS and gridmapdir
include lcmaps

# StoRM dependencies
package { 'attr':
  ensure => latest,
}

# Storage area root directories
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

# Create testsuite fixture
exec { 'apply-fixtures':
  command => '/bin/bash /assets/node/fixture.sh',
}

# Install BDII
class { 'bdii':
  firewall   => false,
  bdiipasswd => 'supersecretpassword',
}

# Ordering

Class['storm::users']
-> Class['lcmaps']

Storm::Sarootdir[$storage_area_root_directories]
-> Exec['apply-fixtures']
