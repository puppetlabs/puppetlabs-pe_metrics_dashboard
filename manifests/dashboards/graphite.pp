class pe_metrics_dashboard::dashboards::graphite(
  Integer $grafana_port      =  $pe_metrics_dashboard::params::grafana_http_port,
  String $grafana_password   =  $pe_metrics_dashboard::params::grafana_password,
  Array[String] $master_list =  $pe_metrics_dashboard::params::master_list,
) inherits pe_metrics_dashboard::params {

  $master_list.each |String $master| {

    grafana_dashboard { "Graphite ${master} Performance":
      grafana_url      => "http://localhost:${grafana_port}",
      grafana_user     => 'admin',
      grafana_password => $grafana_password,
      content          => epp('pe_metrics_dashboard/Graphite_Puppetserver_Performance.json.epp',
        {master => $master}),
      require          => Grafana_datasource['influxdb_graphite'],
    }
  }
}
