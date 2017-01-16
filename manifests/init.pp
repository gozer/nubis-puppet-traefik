# Class: nubis_traefik
# ===========================
#
# Full description of class nubis_traefik here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'nubis_traefik':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2017 Your name here, unless otherwise noted.
#

class nubis_traefik($version = '1.1.2') {
  $traefik_url = "https://github.com/containous/traefik/releases/download/v${traefik_version}/traefik_linux-amd64"

  notice ("Grabbing traefik ${traefik_version}")

  staging::file { '/usr/local/bin/traefik':
    source => $traefik_url,
    target => '/usr/local/bin/traefik',
  }->
  exec { 'chmod /usr/local/bin/traefik':
    command => 'chmod 755 /usr/local/bin/traefik',
    path    => ['/sbin','/bin','/usr/sbin','/usr/bin','/usr/local/sbin','/usr/local/bin'],
  }

  file { '/etc/traefik':
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0640',
  }
}
