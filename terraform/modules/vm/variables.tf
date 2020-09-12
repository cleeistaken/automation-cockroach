#
# vSphere
#
variable vsphere_cluster_index {
  type = number
  default = 0
}

variable vsphere_cluster {
  type = object({
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

    # Virtual machine domain name
    vs_vm_domain = string

    # Virtual Machine DNS servers
    vs_vm_dns = list(string)

    # Virtual Machine DNS suffixes
    vs_vm_dns_suffix = list(string)
  })
}

#
# VM Parameters
#
variable vm_count {
  description = "Number of VM to create"
  type = number
}

variable vm_name_prefix {
  description = "VM name prefix"
  type = string
}

variable vm_cpu_count {
  description = "Number of vCPU"
  type = number
}

variable vm_memory_gb {
  description = "Amount of RAM in GB"
  type = number
}

variable vm_os_disk_gb {
  description = "VM OS disk size in GB"
  type = number
}

variable vm_data_disk_count {
  description = "Number of Data disks"
  type = number
  default = 0
}

variable vm_data_disk_gb {
  description = "VM Data disk size in GB"
  type = number
  default = 0
}

variable vm_hw_version {
  description = "VM hardware version (>= than template)"
  type = number
}

variable vm_ip_offset {
  description = "VM IP offset in cluster range"
  type = number
  default = 0
}

variable vm_anti_affinity {
  description = "VM need anti-affinity"
  type = bool
  default = true
}