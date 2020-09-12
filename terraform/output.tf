output "crdb_client" {
  value = module.crdb_client
}

output "crdb" {
  value = module.crdb
}

module "inventory" {
  source  = "./modules/inventory"
  crdb_client_servers = {
  for x in module.crdb_client: x.vm.name => {
    ips = x.vm.hosts,
    hostnames_short = x.vm.hostnames,
    hostnames_long = [ for y in x.vm.hostnames:  "${y}.${x.vm.domain}" ]
  }
  }
  crdb_servers = {
    for x in module.crdb: x.vm.name => {
      ips = x.vm.hosts,
      hostnames_short = x.vm.hostnames,
      hostnames_long = [ for y in x.vm.hostnames:  "${y}.${x.vm.domain}" ]
    }
  }

  output_folder = "../ansible/"
}

