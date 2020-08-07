$backend='backend.test.example'
$frontend='frontend.test.example'
$webdav='webdav.test.example'
$gridftp='gridftp.test.example'

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

exec { 'apply-fixtures':
  command     => '/bin/bash /assets/service/fixture.sh',
}

class { 'storm::backend':
  hostname              => $backend,
  mysql_server_install  => true,
  frontend_public_host  => $frontend,
  transfer_protocols    => ['file', 'gsiftp', 'webdav', 'xroot'],
  xmlrpc_security_token => 'NS4kYAZuR65XJCq',
  service_du_enabled    => true,
  srm_pool_members      => [
    {
      'hostname' => $frontend,
    }
  ],
  gsiftp_pool_members   => [
    {
      'hostname' => $gridftp,
    },
  ],
  webdav_pool_members   => [
    {
      'hostname' => $webdav,
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

class { 'bdii':
  firewall => false,
}


Class['storm::users']
-> Class['storm::storage']
-> Class['storm::gridmap']
-> Class['storm::backend']
-> Exec['apply-fixtures']
-> Class['bdii']

