#
# vSphere vCenter Server
#
variable vcenter_server {
  description = "vCenter Server hostname or IP"
  type = string
}

variable vcenter_user {
  description = "vCenter Server username"
  type = string
}

variable vcenter_password {
  description = "vCenter Server password"
  type = string
}

variable vcenter_insecure_ssl {
  description = "Allow insecure connection to the vCenter server (unverified SSL certificate)"
  type = bool
  default = false
}

#
# vSphere Clusters
#
variable vsphere_clusters {
  type = list(object({
    # vSphere Datacenter
    vs_dc = string

    # vSphere Cluster in the Datacenter
    vs_cls = string

    # vSphere Resource Pool
    vs_rp = string

    # vSphere Distributed Virtual Switch
    vs_dvs = string

    # vSphere Distributed Portgroup
    vs_dvs_pg_1 = string

    # Portgroup 1 IPv4 subnet in CIDR notation (e.g. 10.0.0.0/24)
    vs_dvs_pg_1_ipv4_subnet = string

    # Portgroup 1 IPv4 address based on the subnet
    # Ref. https://www.terraform.io/docs/configuration/functions/cidrhost.html
    vs_dvs_pg_1_ipv4_start_hostnum = number

    # Portgroup 1 IPv4 gateway address
    vs_dvs_pg_1_ipv4_gw = string

    # vSphere vSAN datastore
    vs_ds = string

    # vSphere vSAN Storage Policy
    vs_ds_sp = string

    # Virtual Machine template to clone from
    vs_vm_template = string

    # Virtual Machine template boot mode (bios/efi)
    vs_vm_template_boot = string

    # Virtual machine domain name
    vs_vm_domain = string

    # Virtual Machine DNS servers
    vs_vm_dns = list(string)

    # Virtual Machine DNS suffixes
    vs_vm_dns_suffix = list(string)
  }))
}

#
# CRDB Client
#
variable crdb_client_vm_per_cluster {
  type = number
}

variable crdb_client_cpu_count {
  type = number
  default = 4
}

variable crdb_client_memory_gb {
  type = number
  default = 16384
}

variable crdb_client_hw_version {
  type = number
  default = 17
}

variable crdb_client_os_disk_gb {
  type = number
  default = 100
}

variable crdb_client_name_prefix {
  type = string
  default = "crdb-client"
}



#
# CRDB
#
variable crdb_vm_per_cluster {
  type = number
}

variable crdb_cpu_count {
  type = number
  default = 4
}

variable crdb_memory_gb {
  type = number
  default = 16384
}

variable crdb_hw_version {
  type = number
  default = 17
}

variable crdb_os_disk_gb {
  type = number
  default = 100
}

variable crdb_data_disk_count {
  type = number
  default = 1
}

variable crdb_data_disk_gb {
  type = number
  default = 250
}

variable crdb_name_prefix {
  type = string
  default = "crdb"
}

