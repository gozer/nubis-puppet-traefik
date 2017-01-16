class nubis_traefik($version = '1.1.2', $tag="monitoring", $project=undef) {
  $traefik_url = "https://github.com/containous/traefik/releases/download/v${version}/traefik_linux-amd64"

  if (!$project) {
    $project = $::project_name
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
    ensure => '2.4.7-1ubuntu4.13'
  }

  upstart::job { 'traefik':
    description    => 'Traefik Load Balancer',
    service_ensure => 'stopped',
    require        => [
      Staging::File['/usr/local/bin/traefik'],
    ],
    # Never give up
    respawn        => true,
    respawn_limit  => 'unlimited',
    start_on       => '(local-filesystems and net-device-up IFACE!=lo)',
    env            => {
      'SLEEP_TIME' => 1,
      'GOMAXPROCS' => 2,
    },
    user           => 'root',
    group          => 'root',
    script         => '
  if [ -r /etc/profile.d/proxy.sh ]; then
    echo "Loading Proxy settings"
    . /etc/profile.d/proxy.sh
  fi

  exec /usr/local/bin/traefik --web.readonly=true --loglevel=INFO
',
    post_stop      => '
goal=$(initctl status $UPSTART_JOB | awk \'{print $2}\' | cut -d \'/\' -f 1)
if [ $goal != "stop" ]; then
    echo "Backoff for $SLEEP_TIME seconds"
    sleep $SLEEP_TIME
    NEW_SLEEP_TIME=`expr 2 \* $SLEEP_TIME`
    if [ $NEW_SLEEP_TIME -ge 60 ]; then
        NEW_SLEEP_TIME=60
    fi
    initctl set-env SLEEP_TIME=$NEW_SLEEP_TIME
fi
',
  }
}
