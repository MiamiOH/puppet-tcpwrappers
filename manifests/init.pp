# = Class: tcpwrappers
#
# This is the main tcpwrappers class
#
#
# == Parameters
#
# Standard class parameters
# Define the general class behaviour and customizations
#
# [*my_class*]
#   Name of a custom class to autoload to manage module's customizations
#   If defined, tcpwrappers class will automatically "include $my_class"
#   Can be defined also by the (top scope) variable $tcpwrappers_my_class
#
# [*allow_file*]
# [*deny_file*]
#   Main configuration file for allow/deny.
#   Default: /etc/hosts.allow
#            /etc/hosts.deny
#
# [*allow_source*]
# [*deny_source*]
#   Sets the content of source parameter for main configuration file
#   If defined, tcpwrappers main config files will have the param:
#   source => $allow_source
#   in the case of hosts.allow or to deny_source in the case of hosts.deny.
#
# [*allow_template*]
# [*deny_template*]
#   Sets the path to the template to use as content for main configuration file
#   If defined, tcpwrappers main config file has: content => content("$template")
#   Note source and template parameters are mutually exclusive: don't use both
#   No templates are provided with the module.
#
# [*options*]
#   An hash of custom options to be used in templates for arbitrary settings.
#   Can be defined also by the (top scope) variable $tcpwrappers_options
#
# [*version*]
#   The package version, used in the ensure parameter of package type.
#   Default: present. Can be 'latest' or a specific version number.
#   Note that if the argument absent (see below) is set to true, the
#   package is removed, whatever the value of version parameter.
#
# [*audit_only*]
#   Set to 'true' if you don't intend to override existing configuration files
#   and want to audit the difference between existing files and the ones
#   managed by Puppet.
#   Can be defined also by the (top scope) variables $tcpwrappers_audit_only
#   and $audit_only
#
# [*noops*]
#   Set noop metaparameter to true for all the resources managed by the module.
#   Basically you can run a dryrun for this specific module if you set
#   this to true. Default: false
#
# Default class params - As defined in tcpwrappers::params.
# Note that these variables are mostly defined and used in the module itself,
# overriding the default values might not affected all the involved components.
# Set and override them only if you know what you're doing.
# Note also that you can't override/set them via top scope variables.
#
# [*package*]
#   The name of tcpwrappers package. REALLY you don't want to mess with this
#   package, unless you know what you're doing.
#
# [*config_dir*]
#   Main configuration directory. Don't see a reason to touch it.
#   Default: /etc
#
#
# == Examples
#
# You can use this class in 2 ways:
# - Set variables (at top scope level on in a ENC) and "include tcpwrappers"
# - Call tcpwrappers as a parametrized class
#
# See README for details.
#
#
class tcpwrappers (
  String                $my_class       = $tcpwrappers::params::my_class,
  String                $allow_file     = $tcpwrappers::params::allow_file,
  String                $allow_source   = $tcpwrappers::params::allow_source,
  String                $deny_source    = $tcpwrappers::params::deny_source,
  String                $deny_file      = $tcpwrappers::params::deny_file,
  String                $allow_template = $tcpwrappers::params::allow_template,
  String                $deny_template  = $tcpwrappers::params::deny_template,
  Variant[String, Hash] $options        = $tcpwrappers::params::options,
  String                $version        = $tcpwrappers::params::version,
  Boolean               $audit_only     = $tcpwrappers::params::audit_only,
  Boolean               $noops          = $tcpwrappers::params::noops,
  String                $package        = $tcpwrappers::params::package,
  String                $config_dir     = $tcpwrappers::params::config_dir
) inherits tcpwrappers::params {

  $config_file_mode  = $tcpwrappers::params::config_file_mode
  $config_file_owner = $tcpwrappers::params::config_file_owner
  $config_file_group = $tcpwrappers::params::config_file_group

  # Definition of some variables used in the module
  $manage_package = $tcpwrappers::version ? {
    ''      => 'present',
    default => $tcpwrappers::version,
  }

  $manage_file = 'present'

  $manage_audit = $tcpwrappers::audit_only ? {
    true  => 'all',
    false => undef,
  }

  $manage_file_replace = $tcpwrappers::audit_only ? {
    true  => false,
    false => true,
  }

  $manage_allow_file_source = $tcpwrappers::allow_source ? {
    ''        => undef,
    default   => $tcpwrappers::allow_source,
  }

  $manage_allow_file_content = $tcpwrappers::allow_template ? {
    ''        => undef,
    default   => template($tcpwrappers::allow_template),
  }

  $manage_deny_file_source = $tcpwrappers::deny_source ? {
    ''        => undef,
    default   => $tcpwrappers::deny_source,
  }

  $manage_deny_file_content = $tcpwrappers::deny_template ? {
    ''        => undef,
    default   => template($tcpwrappers::deny_template),
  }

  # Managed resources
  package { $tcpwrappers::package:
    ensure => $tcpwrappers::manage_package,
    noop   => $tcpwrappers::noops,
  }

  file { 'allow.file':
    ensure  => $tcpwrappers::manage_file,
    path    => $tcpwrappers::allow_file,
    mode    => $tcpwrappers::config_file_mode,
    owner   => $tcpwrappers::config_file_owner,
    group   => $tcpwrappers::config_file_group,
    require => Package[$tcpwrappers::package],
    source  => $tcpwrappers::manage_allow_file_source,
    content => $tcpwrappers::manage_allow_file_content,
    replace => $tcpwrappers::manage_file_replace,
    audit   => $tcpwrappers::manage_audit,
    noop    => $tcpwrappers::noops,
  }

  file { 'deny.file':
    ensure  => $tcpwrappers::manage_file,
    path    => $tcpwrappers::deny_file,
    mode    => $tcpwrappers::config_file_mode,
    owner   => $tcpwrappers::config_file_owner,
    group   => $tcpwrappers::config_file_group,
    require => Package[$tcpwrappers::package],
    source  => $tcpwrappers::manage_deny_file_source,
    content => $tcpwrappers::manage_deny_file_content,
    replace => $tcpwrappers::manage_file_replace,
    audit   => $tcpwrappers::manage_audit,
    noop    => $tcpwrappers::noops,
  }

  # Include custom class if $my_class is set
  if $tcpwrappers::my_class != '' {
    include $tcpwrappers::my_class
  }

}
