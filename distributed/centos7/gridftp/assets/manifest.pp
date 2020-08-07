include storm::users
include storm::gridmap

class { 'storm::storage':
  root_directories => [
    '/storage',
    '/storage/test.vo',
    '/storage/test.vo.2',
    '/storage/igi',
    '/storage/noauth',
    '/storage/test.vo.bis',
    '/storage/nested',
    '/storage/tape',
  ],
}

class { 'storm::gridftp':
  redirect_lcmaps_log => true,
  llgt_log_file       => '/var/log/storm/storm-gridftp-lcmaps.log',
}

Class['storm::users']
-> Class['storm::storage']
-> Class['storm::gridmap']
-> Class['storm::gridftp']
