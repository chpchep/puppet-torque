# Torque server installation
#
class torque::server(
  $server_ensure  = 'present',
  $service_name   = 'torque-server',
  $service_ensure = 'running',
  $service_enable = true,
  # the following options are protected from being unset
  # if they don't appear in torque_qmgr_server
  $qmgr_present   = [
    'acl_hosts',
    'node_check_rate',
    'tcp_timeout',
    'next_job_number',
  ],
  $qmgr_conf      = [
    "acl_hosts = ${::fqdn}",
    'node_check_rate = 150',
    'tcp_timeout = 6',
    'next_job_number = 0',
    'scheduling = True',
    'acl_host_enable = False',
    "managers = root@${::fqdn}",
    "operators = root@${::fqdn}",
    'default_queue = dteam',
    'log_events = 511',
    'mail_from = adm',
    'mail_domain = never',
    'query_other_jobs = True',
    'scheduler_iteration = 600',
    'default_node = lcgpro',
    'node_pack = False',
    'kill_delay = 10',
# attribute doesn't seem to be supported
# in all versions
#    "authorized_users = *@${::fqdn}",
  ],
  $qmgr_queue_defaults = [
    'queue_type = Execution',
    'resources_max.cput = 48:00:00',
    'resources_max.walltime = 72:00:00',
    'enabled = True',
    'started = True',
    'acl_group_enable = True',
  ],
   # default queue definitions
  # empty, because queues are not set up by default
  # this is a hash with the queue name as key and an array of configuration options as value
  # if no value is specified then the default options array ($qmgr_qdefaults) is used
  $qmgr_queues  = {},
  $enable_maui  = true,
  $enable_munge = false,
) inherits torque {

  validate_bool($enable_maui)
  validate_bool($enable_munge)

  package { 'torque-server':
    ensure => $server_ensure,
  }

  class { 'torque::server::config':
    qmgr_server         => $qmgr_conf,
    qmgr_present        => $qmgr_present,
    qmgr_queue_defaults => $qmgr_queue_defaults,
    qmgr_queues         => $qmgr_queues,
  }

  service { $service_name:
    ensure     => $service_ensure,
    enable     => $service_enable,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['torque-server'],
    subscribe  => File['/etc/torque/server_name'],
  }

  if($enable_maui){
    class { 'torque::maui': }
  }

  if($enable_munge) {
    class { 'torque::munge': }
  }
}
