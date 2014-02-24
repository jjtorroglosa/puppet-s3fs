# Class: s3fs::mount
#
# This module installs s3fs
#
# Parameters:
#
#  [*bucket*]      - AWS bucket name
#  [*mount_point*] - Mountpoint for bucket
#  [*ensure*]      - Set mountpoint values, ensure dir and mount are absent
#  [*s3url*]       - 'https://s3.amazonaws.com'
#  [*default_acl*] - 'private'
#  [*uid*]         - Mountpoint and mount dir owner
#  [*gid*]         - Mountpoint and mount dir group
#  [*mode*]        - Mountpoint and moutn dir permissions
#  [*atboot*]      - 'true',
#  [*device*]      - "s3fs#${bucket}",
#  [*fstype*]      - 'fuse',
#  [*remounts*]    - 'false',
#  [*cache*]       - '/tmp/aws_s3_cache',
#  [*allow_other*] - 'true',
#  [*netdev*]      - false, Includes the _netdev option in fstab
#
# Actions:
#
# Requires:
#  Class['s3fs']
#
# Sample Usage:
#
# # S3FS
#  s3fs::mount {'Testing':
#    bucket      => 'testvgh1',
#    mount_point => '/srv/testvgh1',
#    uid         => '1001',
#    gid         => '1001',
#  }
# ## S3FS
#  s3fs::mount {'Testvgh':
#    bucket      => 'testvgh',
#    mount_point => '/srv/testvgh2',
#    default_acl => 'public-read',
#  }
#
define s3fs::mount (
  $bucket,
  $mount_point,
  $ensure      = 'present',
  $s3url       = 'https://s3.amazonaws.com',
  $default_acl = 'private',
  $uid         = '0',
  $gid         = '0',
  $mode        = '0660',
  $atboot      = 'true',
  $device      = "s3fs#${bucket}",
  $fstype      = 'fuse',
  $remounts    = 'false',
  $cache       = '/tmp/aws_s3_cache',
  $allow_other = true,
  $netdev      = false,
) {

  Class['s3fs'] -> S3fs::Mount["${name}"]

  # Declare this here, otherwise, uid, guid, etc.. are not initialized in the correct order.

  $allow_other_str = $allow_other ? {
    true => "allow_other",
    false => 'undef'
  }
  $netdev_str = $netdev ? {
    true => "_netdev",
    false => 'undef'
  }

  $uid_str = "uid=${uid}"
  $gid_str = "gid=${gid}"
  $default_acl_str = "default_acl=${default_acl}"
  $use_cache_str = "use_cache=${use_cache}"
  $url_str = "url=${s3url}"

  $options_arr = [$allow_other_str, $uid_str, $gid_str, $default_acl_str, $use_cache_str, $url_str, $netdev_str]
  $options = join(reject($options_arr, 'undef'), ",")

  case $ensure {
    present, defined, unmounted, mounted: {
      $ensure_dir = 'directory'
    }
    absent: {
      $ensure_dir = 'absent'
    }
    default: {
      fail("Not a valid ensure value: ${ensure}")
    }
  }

  File["${mount_point}"] -> Mount["${mount_point}"]

  file { $mount_point:
    ensure  => $ensure_dir,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
  }

  mount{ $mount_point:
    ensure   => $ensure,
    atboot   => $atboot,
    device   => $device,
    fstype   => $fstype,
    options  => $options,
    remounts => $remounts,
  }

}
