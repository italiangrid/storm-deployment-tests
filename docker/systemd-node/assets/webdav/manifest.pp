class { 'storm::users': }
-> class { 'storm::webdav':
  use_conscrypt => true,
  enable_http2  => true,
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
  hostnames     => ['webdav.test.example']
}
