class { 'storm::users': }
-> class { 'storm::frontend':
  be_xmlrpc_host  => 'backend.test.example',
  be_xmlrpc_token => 'NS4kYAZuR65XJCq',
  db_host         => 'backend.test.example',
  db_user         => 'storm',
  db_passwd       => 'storm',
}
