# Class: pe_metrics_dashboard
# ===========================
#
# The pe_metrics_dashboard module installs and configures an InfluxDB stack
# monitor the Puppet Enterprise infrastructure components.
#
# Parameters
# ----------
#
# * `add_dashboard_examples`
# Whether to add the Grafana dashboard example dashboards for the configured InfluxDB databases.
# Valid values are `true`, `false`. Defaults to `false`.
# *Note:* These dashboards are managed and any changes will be overwritten unless the `overwrite_dashboards` is set to `false`.
#
# * `manage_repos`
# Whether or not to setup yum / apt repositories for the dependent packages
# Valid values are `true`, `false`. Defaults to `true`
#
# * `dashboard_cert_file`
# The location of the Grafana certficiate.
# Defaults to `"/etc/grafana/${clientcert}_cert.pem"`
# Only used when configuring `use_dashboard_ssl` is true.
#
# * `dashboard_cert_key`
# The location of the Grafana private key.
# Defaults to `"/etc/grafana/${clientcert}_key.pem"`
# Only used when configuring `use_dashboard_ssl` is true.
#
# * `configure_telegraf`
# Whether to configure the telegraf service.
# Valid values are `true`, `false`. Defaults to `true`
# This parameter enables configuring telegraf to query the `master_list` and `puppetdb_list` endpoints for metrics. Metrics will be stored in the `telegraf` database in InfluxDb. Ensure that `influxdb_database_name` contains `telegraf` when using this parameter.
# _Note:_ This parameter is only used if `enable_telegraf` is set to true.
#
# * `consume_graphite`
# Whether to enable the InfluxDB Graphite plugin.
# Valid values are `true`, `false`. Defaults to `false`
# This parameter enables the Graphite plugin for InfluxDB to allow for injesting Graphite metrics. Ensure `influxdb_database_name` contains `graphite` when using this parameter.
# *Note:* If using Graphite metrics from the Puppet Master, this needs to be set to `true`.
#
# * `grafana_http_port`
# The port to run Grafana on.
# Valid values are Integers from `1024` to `65536`. Defaults to `3000`
# The grafana port for the web interface. This should be a nonprivileged port (above 1024).
#
# * `grafana_password`
# The password for the Grafana admin user.
# Defaults to `'admin'`
#
# * `grafana_version`
# The grafana version to install.
# Valid values are String versions of Grafana. Defaults to `'4.5.2'`
#
# * `influxdb_database_name`
# An array of databases that should be created in InfluxDB.
# Valid values are 'pe_metrics','telegraf', 'graphite', and any other string. Defaults to `['pe_metrics']`
# Each database in the array will be created in InfluxDB. 'pe_metrics','telegraf', and 'graphite' are specially named and will be used with their associated metric collection method. Any other database name will be created, but not utilized with components in this module.
#
# * `influx_db_password`
# The password for the InfluxDB admin user.
# Defaults to `'puppet'`
#
# * `enable_kapacitor`
# Whether to install kapacitor.
# Valid values are `true`, `false`. Defaults to `false`
# Install kapacitor. No configuration of kapacitor is included at this time.
#
# * `enable_chronograf`
# Whether to install chronograf.
# Valid values are `true`, `false`. Defaults to `false`
# Installs chronograf. No configuration of chronograf is included at this time.
#
# * `enable_telegraf`
# Whether to install telegraf.
# Valid values are `true`, `false`. Defaults to `false`
# Installs telegraf. No configuration is done unless the `configure_telegraf` parameter is set to `true`.
#
# * `master_list`
# An array of Puppet Master servers to collect metrics from. Defaults to `["$::settings::certname"]`
# A list of Puppet master servers that will be configured for telegraf to query.
#
# * `overwrite_dashboards`
# Whether to overwrite the example Grafana dashboards.
# Valid values are `true`, `false`. Defaults to `false`
# This paramater disables overwriting the example Grafana dashboards. It takes effect after the second Puppet run and popultes the `overwrite_dashboards_disabled` fact. This only takes effect when `add_dashboard_examples` is set to true.
#
# * `puppetdb_list`
# An array of PuppetDB servers to collect metrics from. Defaults to `["$::settings::certname"]`
# A list of PuppetDB servers that will be configured for telegraf to query.
#
# * `use_dashboard_ssl`
# Whether to enable SSL on Grafana.
#
# Valid values are `true`, `false`. Defaults to `false`

# Examples
# --------
#
# @example
#    class { 'pe_metrics_dashboard':
#      configure_telegraf  => true,
#      enable_telegraf     => true,
#      master_list         => ['master1.com','master2.com'],
#      puppetdb_list       => ['puppetdb1','puppetdb2'],
#    }
#
#
# Summary
# -------
# @summary Installs and configures Grafana with InfluxDB for monitoring PE.
#
# Authors
# -------
#
# Erik Hansen <erik.hansen@puppet.com>
# Jarret Lavallee <jarret@puppet.com>

class pe_metrics_dashboard (
  Boolean $add_dashboard_examples         =  $pe_metrics_dashboard::params::add_dashboard_examples,
  Boolean $manage_repos                   =  $pe_metrics_dashboard::params::manage_repos,
  Boolean $use_dashboard_ssl              =  $pe_metrics_dashboard::params::use_dashboard_ssl,
  String $dashboard_cert_file             =  $pe_metrics_dashboard::params::dashboard_cert_file,
  String $dashboard_cert_key              =  $pe_metrics_dashboard::params::dashboard_cert_key,
  Boolean $overwrite_dashboards           =  $pe_metrics_dashboard::params::overwrite_dashboards,
  String $overwrite_dashboards_file       =  $pe_metrics_dashboard::params::overwrite_dashboards_file,
  String $influx_db_service_name          =  $pe_metrics_dashboard::params::influx_db_service_name,
  Array[String] $influxdb_database_name   =  $pe_metrics_dashboard::params::influxdb_database_name,
  String $grafana_version                 =  $pe_metrics_dashboard::params::grafana_version,
  Integer $grafana_http_port              =  $pe_metrics_dashboard::params::grafana_http_port,
  String $influx_db_password              =  $pe_metrics_dashboard::params::influx_db_password,
  String $grafana_password                =  $pe_metrics_dashboard::params::grafana_password,
  Boolean $enable_kapacitor               =  $pe_metrics_dashboard::params::enable_kapacitor,
  Boolean $enable_chronograf              =  $pe_metrics_dashboard::params::enable_chronograf,
  Boolean $enable_telegraf                =  $pe_metrics_dashboard::params::enable_telegraf,
  Boolean $configure_telegraf             =  $pe_metrics_dashboard::params::configure_telegraf,
  Boolean $consume_graphite               =  $pe_metrics_dashboard::params::consume_graphite,
  Array[String] $master_list              =  $pe_metrics_dashboard::params::master_list,
  Array[String] $puppetdb_list            =  $pe_metrics_dashboard::params::puppetdb_list
  ) inherits pe_metrics_dashboard::params {

    class { 'pe_metrics_dashboard::install':
    add_dashboard_examples    =>  $add_dashboard_examples,
    manage_repos              =>  $manage_repos,
    use_dashboard_ssl         =>  $use_dashboard_ssl,
    dashboard_cert_file       =>  $dashboard_cert_file,
    dashboard_cert_key        =>  $dashboard_cert_key,
    overwrite_dashboards      =>  $overwrite_dashboards,
    overwrite_dashboards_file =>  $overwrite_dashboards_file,
    influx_db_service_name    =>  $influx_db_service_name,
    influxdb_database_name    =>  $influxdb_database_name,
    grafana_version           =>  $grafana_version,
    grafana_http_port         =>  $grafana_http_port,
    influx_db_password        =>  $influx_db_password,
    grafana_password          =>  $grafana_password,
    enable_kapacitor          =>  $enable_kapacitor,
    enable_chronograf         =>  $enable_chronograf,
    enable_telegraf           =>  $enable_telegraf,
    configure_telegraf        =>  $configure_telegraf,
    consume_graphite          =>  $consume_graphite,
    master_list               =>  $master_list,
    puppetdb_list             =>  $puppetdb_list,
  }
}
