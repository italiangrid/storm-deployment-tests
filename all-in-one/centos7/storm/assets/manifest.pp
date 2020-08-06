$host='storm.test.example'


Class['storm::backend']
-> Class['storm::frontend']
-> Class['storm::gridftp']
-> Class['storm::webdav']

class { 'storm::backend':
  hostname              => $host,
  mysql_server_install  => true,
  transfer_protocols    => ['file', 'gsiftp', 'webdav', 'xroot'],
  xmlrpc_security_token => 'NS4kYAZuR65XJCq',
  db_username           => 'storm',
  db_password           => 'storm',
  service_du_enabled    => true,
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
  lcmaps_debug_level    => 5,
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
  storage_areas => [
    {
      'name'                       => 'test.vo',
      'root_path'                  => '/storage/test.vo',
      'access_points'              => ['/test.vo'],
      'vos'                        => ['test.vo'],
      'authenticated_read_enabled' => false,
      'anonymous_read_enabled'     => false,
      'vo_map_enabled'             => false,
    },
    {
      'name'                       => 'test.vo.2',
      'root_path'                  => '/storage/test.vo.2',
      'access_points'              => ['/test.vo.2'],
      'vos'                        => ['test.vo.2'],
      'authenticated_read_enabled' => false,
      'anonymous_read_enabled'     => false,
      'vo_map_enabled'             => false,
    },
    {
      'name'                       => 'igi',
      'root_path'                  => '/storage/igi',
      'access_points'              => ['/igi'],
      'vos'                        => ['test.vo'],
      'authenticated_read_enabled' => true,
      'anonymous_read_enabled'     => false,
      'vo_map_enabled'             => false,
    },
    {
      'name'                       => 'noauth',
      'root_path'                  => '/storage/noauth',
      'access_points'              => ['/noauth'],
      'vos'                        => ['test.vo'],
      'authenticated_read_enabled' => true,
      'anonymous_read_enabled'     => true,
      'vo_map_enabled'             => false,
    },
    {
      'name'                       => 'test.vo.bis',
      'root_path'                  => '/storage/test.vo.bis',
      'access_points'              => ['/test.vo.bis'],
      'vos'                        => ['test.vo.2'],
      'authenticated_read_enabled' => false,
      'anonymous_read_enabled'     => false,
      'vo_map_enabled'             => false,
    },
    {
      'name'                       => 'nested',
      'root_path'                  => '/storage/nested',
      'access_points'              => ['/test.vo.2/nested', '/alias'],
      'vos'                        => ['test.vo.2'],
      'authenticated_read_enabled' => false,
      'anonymous_read_enabled'     => false,
      'vo_map_enabled'             => false,
    },
    {
      'name'                       => 'tape',
      'root_path'                  => '/storage/tape',
      'access_points'              => ['/tape'],
      'vos'                        => ['test.vo.2'],
      'authenticated_read_enabled' => false,
      'anonymous_read_enabled'     => false,
      'vo_map_enabled'             => false,
    },
  ],
  hostnames     => [$host]
}
