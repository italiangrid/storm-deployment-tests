$host='storm.test.example'
$xmlrpc_token='NS4kYAZuR65XJCq'

include storm::db

class { 'storm::backend':
  transfer_protocols    => ['gsiftp', 'webdav', 'xroot'],
  xmlrpc_security_token => $xmlrpc_token,
  service_du_enabled    => true,
  lcmaps_debug_level    => 5,
  path_authz_db_file    => '/assets/services/path-authz.db',
  srm_pool_members      => [
    {
      'hostname' => $host,
    },
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

storm::backend::storage_site_report { 'storage-site-report':
  report_path => '/storage/info/report.json',
  minute      => '*/20',
}

class { 'storm::frontend':
  be_xmlrpc_host  => $host,
  be_xmlrpc_token => $xmlrpc_token,
}

class { 'storm::gridftp':
  redirect_lcmaps_log => true,
  llgt_log_file       => '/var/log/storm/storm-gridftp-lcmaps.log',
  lcmaps_debug_level  => 5,
  lcas_debug_level    => 5,
}

class { 'storm::webdav':
  hostnames => [$host],
}

# WebDAV configuration
storm::webdav::application_file { 'application.yml':
  source => '/assets/services/application.yml',
}
storm::webdav::storage_area_file { 'test.vo.properties':
  source => '/assets/services/sa.d/test.vo.properties',
}
storm::webdav::storage_area_file { 'test.vo.2.properties':
  source => '/assets/services/sa.d/test.vo.2.properties',
}
storm::webdav::storage_area_file { 'test.vo.bis.properties':
  source => '/assets/services/sa.d/test.vo.bis.properties',
}
storm::webdav::storage_area_file { 'tape.properties':
  source => '/assets/services/sa.d/tape.properties',
}
storm::webdav::storage_area_file { 'info.properties':
  source => '/assets/services/sa.d/info.properties',
}
storm::webdav::storage_area_file { 'noauth.properties':
  source => '/assets/services/sa.d/noauth.properties',
}
storm::webdav::storage_area_file { 'igi.properties':
  source => '/assets/services/sa.d/igi.properties',
}

exec { 'restart-bdii':
  command => '/bin/systemctl restart bdii',
}

Class['storm::db']
-> Class['storm::backend']
-> Class['storm::frontend']
-> Class['storm::gridftp']
-> Class['storm::webdav']
-> Exec['restart-bdii']
