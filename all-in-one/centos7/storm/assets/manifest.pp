$host='storm.test.example'

include storm::db

class { 'storm::backend':
  hostname              => $host,
  transfer_protocols    => ['file', 'gsiftp', 'webdav', 'xroot'],
  xmlrpc_security_token => 'NS4kYAZuR65XJCq',
  db_username           => 'storm',
  db_password           => 'storm',
  service_du_enabled    => true,
  lcmaps_debug_level    => 5,
  srm_pool_members      => [
    {
      'hostname' => $host,
    }
  ],
  gsiftp_pool_members   => [
    {
      'hostname' => $host,
    },
  ],
  webdav_pool_members   => [
    {
      'hostname' => $host,
    },
  ],
  storage_areas         => [
    {
      'name'          => 'test.vo',
      'root_path'     => '/storage/test.vo',
      'access_points' => ['/test.vo'],
      'vos'           => ['test.vo'],
      'online_size'   => 4,
    },
    {
      'name'          => 'test.vo.2',
      'root_path'     => '/storage/test.vo.2',
      'access_points' => ['/test.vo.2'],
      'vos'           => ['test.vo.2'],
      'online_size'   => 4,
    },
    {
      'name'          => 'igi',
      'root_path'     => '/storage/igi',
      'access_points' => ['/igi'],
      'vos'           => ['test.vo'],
      'online_size'   => 4,
    },
    {
      'name'          => 'noauth',
      'root_path'     => '/storage/noauth',
      'access_points' => ['/noauth'],
      'vos'           => ['test.vo'],
      'online_size'   => 4,
    },
    {
      'name'          => 'test.vo.bis',
      'root_path'     => '/storage/test.vo.bis',
      'access_points' => ['/test.vo.bis'],
      'vos'           => ['test.vo.2'],
      'online_size'   => 4,
    },
    {
      'name'          => 'nested',
      'root_path'     => '/storage/nested',
      'access_points' => ['/test.vo.2/nested', '/alias'],
      'vos'           => ['test.vo.2'],
      'online_size'   => 4,
    },
    {
      'name'          => 'tape',
      'root_path'     => '/storage/tape',
      'access_points' => ['/tape'],
      'vos'           => ['test.vo.2'],
      'online_size'   => 4,
      'nearline_size' => 8,
      'fs_type'       => 'test',
      'storage_class' => 'T1D0',
    },
  ],
}

class { 'storm::frontend':
  be_xmlrpc_host  => $host,
  be_xmlrpc_token => 'NS4kYAZuR65XJCq',
  db_user         => 'storm',
  db_passwd       => 'storm',
}

class { 'storm::gridftp':
  redirect_lcmaps_log => true,
  llgt_log_file       => '/var/log/storm/storm-gridftp-lcmaps.log',
  lcmaps_debug_level  => 5,
  lcas_debug_level    => 5,
}

class { 'storm::webdav':
  storage_areas_directory => '/assets/service/sa.d',
  hostnames               => [$host]
}

file { '/root/update-site-report.sh':
  ensure => 'present',
  source => 'puppet:///modules/storm/update-site-report.sh',
}

cron { 'update-site-report':
  ensure  => 'present',
  command => '/bin/bash /root/update-report.sh',
  user    => 'root',
  minute  => '*/30',
  require => File['/root/update-site-report.sh'],
}

exec { 'create-site-report':
  command => '/bin/bash /root/update-site-report.sh',
  require => File['/root/update-site-report.sh'],
}

Class['storm::db']
-> Class['storm::backend']
-> Class['storm::frontend']
-> Class['storm::gridftp']
-> Class['storm::webdav']
-> File['/root/update-site-report.sh']
