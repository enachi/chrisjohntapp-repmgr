# == Class: repmgr::repmgrd_service
# Private class
class repmgr::repmgrd_service
{
  # Ensure repmgrd is running on secondaries and stopped on primary.
  if ($::operatingsystem == 'Ubuntu')
  {
    if ($::replication_tier != 'primary')
    {
      service { 'repmgrd':
        ensure     => running,
        enable     => false,
        hasrestart => true,

      }
    }
    elsif ($::real_primary == 'iamtheprimary') or ($::hostname == $repmgr::primary)
    {
      service { 'repmgrd':
        ensure => stopped,
        enable => false,
      }
    }
  }
  else # Use generic commands.
  {
    if ($::repmgrd_status == 'stopped') and ($::replication_tier == 'secondary')
    {
      exec { 'start_repmgrd':
        user    => $repmgr::postgresql_user,
        command => "/usr/bin/repmgrd -f ${repmgr::repmgr_conf_dir}/repmgr.conf \
        --verbose --monitoring-history \
        >> ${repmgr::repmgr_log_dir}/repmgr.log 2>&1",
      }
    }
    elsif ($::repmgrd_status == 'running') and ($::replication_tier == 'primary')
    {
      exec { 'kill_repmgrd':
        user    => 'root',
        command => '/usr/bin/killall -KILL repmgrd',
      }
    }
  }
}