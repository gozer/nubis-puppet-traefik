class nubis_traefik($version = '1.4.0', $project=undef, $dns=undef) {
  $traefik_url = "https://github.com/containous/traefik/releases/download/v${version}/traefik_linux-amd64"

  if ($project) {
    $traefik_project = $project
  }
  else {
    $traefik_project = $::project_name
  }

  if ($dns) {
    $traefik_dns = $dns
  }
  else {
    $traefik_dns = $traefik_project
  }

  notice ("Grabbing traefik ${version} for ${project}")

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

  file { '/etc/consul/svc-traefik.json':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("${module_name}/svc-traefik.json.tmpl"),
  }

  # For htpasswd
  package {'apache2-utils':
    ensure => 'present',
  }
  package {'apg':
    ensure => 'present',
  }

  systemd::unit_file { 'traefik.service':
    source => "puppet://modules/${module_name}/traefik.systemd",
  }
  ->service { 'traefik':
    enable => true,
  }

  file { '/etc/confd/conf.d/traefik.toml':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template("${module_name}/traefik.toml.tmpl"),
  }

  file { '/etc/confd/templates/traefik.toml.tmpl':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template("${module_name}/traefik.toml.tmpl.tmpl"),
  }

  file { "/etc/nubis.d/${traefik_project}-traefik":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template("${module_name}/startup.tmpl"),
  }
}
