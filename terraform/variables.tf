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

    # Portgroup 1 IPv4 addresses
    vs_dvs_pg_1_ipv4_ips = list(string)

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
  description = "The number of CRDB client VM to create in the vSphere Cluster."
  type = number
}

variable crdb_client_name_prefix {
  description = "The name prefix for the CRDB client VM."
  type = string
  default = "crdb-client"
}

variable crdb_client_vm_anti_affinity {
  description = "Create a DRS anti-affinity rule for the CRDB client VM."
  type = bool
  default = true
}

variable crdb_client {
  description = "CRDB client VM virtual hardware configuration."
  type = object({
    cpu_count = number
    memory_gb = number
    hw_version = number
    os_disk_gb = number
  })
}

#
# CRDB
#
variable crdb_vm_per_cluster {
  description = "The number of CRDB VM to create in the vSphere Cluster."
  type = number
}

variable crdb_name_prefix {
  description = "The name prefix for the CRDB VM."
  type = string
  default = "crdb"
}

variable crdb_vm_anti_affinity {
  description = "Create a DRS anti-affinity rule for the CRDB VM."
  type = bool
  default = true
}

variable crdb {
  description = "CRDB VM virtual hardware configuration."
  type = object({
    cpu_count = number
    memory_gb = number
    hw_version = number
    os_disk_gb = number
    data_disk_count = number
    data_disk_gb = number
  })
}
