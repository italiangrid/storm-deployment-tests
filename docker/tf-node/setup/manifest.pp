include mwdevel_test_ca
include mwdevel_test_vos
class { 'mwdevel_umd_repo':
  umd_repo_version => 4,
}

package { 'ca-policy-egi-core':
  ensure  => installed,
  require => File['egi-trust-anchors.repo'],
}
