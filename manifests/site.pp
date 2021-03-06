require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::home}/homebrew/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

$home = "/Users/${::boxen_user}"
$srcdir = "${home}/src"

repository { "${srcdir}/elemica/mercury" :
  source   => 'https://github.com/elemica/mercury.git',
  path     => "${srcdir}/mercury",
  provider => 'git',
}

repository { "${srcdir}/elemica/chef-repo" :
  source   => 'https://github.com/elemica/chef-repo.git',
  path     => "${srcdir}/chef-repo",
  provider => 'git',
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include git

  # # fail if FDE is not enabled
#   if $::root_encrypted == 'no' {
#     fail('Please enable full disk encryption and try again')
#   }


  # default node versions
  class { 'nodejs::global':
    version => 'v0.10.29'
  }

  nodejs::module { 'coffee-script':
    node_version => 'v0.10.29'
  }

  # default ruby versions
  class { 'ruby::global':
    version => '2.1.2'
  }

  ruby_gem { "compass for 2.1.2":
    gem     => 'compass',
    ruby_version => '2.1.2',
    version => '1.0.0.alpha.19',
  }

  ruby_gem { "sass for 2.1.2":
    gem => 'sass',
    ruby_version => '2.1.2',
    version => ' 3.3.4',
  }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar',
      'snzip',
      'rabbitmq',
      'git-flow-avh',
      'curl'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }

  include java
  include flowdock
  include iterm2::stable
  include tunnelblick
  include github_for_mac
  include firefox
  include chrome
  include skype
  include flux
}
