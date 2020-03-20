include mwdevel_test_vos
include mwdevel_test_ca
include mwdevel_infn_ca
include mwdevel_terena_ca

include ntp
include fetchcrl

class { 'mwdevel_umd_repo':
  umd_repo_version => 4,
}
