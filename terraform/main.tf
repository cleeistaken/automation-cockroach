#
# vSphere Provider
#
provider "vsphere" {
  vsphere_server = var.vcenter_server
  user = var.vcenter_user
  password = var.vcenter_password
  allow_unverified_ssl = var.vcenter_insecure_ssl
}

#
# CRDB Client
#
module "crdb_client" {
  source = "./modules/vm"

  count = length(var.vsphere_clusters)

  vsphere_cluster_index = count.index
  vsphere_cluster = var.vsphere_clusters[count.index]

  # VM parameters
  vm_count            = var.crdb_client_vm_per_cluster
  vm_name_prefix      = var.crdb_client_name_prefix
  vm_cpu_count        = var.crdb_client_cpu_count
  vm_memory_gb        = var.crdb_client_memory_gb
  vm_os_disk_gb       = var.crdb_client_os_disk_gb
  vm_hw_version       = 17
}

#
# CRDB
#
module "crdb" {
  source = "./modules/vm"

  count = length(var.vsphere_clusters)

  vsphere_cluster_index = count.index

  vsphere_cluster = var.vsphere_clusters[count.index]

  # VM parameters
  vm_count            = var.crdb_vm_per_cluster
  vm_name_prefix      = var.crdb_name_prefix
  vm_cpu_count        = var.crdb_cpu_count
  vm_memory_gb        = var.crdb_memory_gb
  vm_os_disk_gb       = var.crdb_os_disk_gb
  vm_data_disk_count  = var.crdb_data_disk_count
  vm_data_disk_gb     = var.crdb_data_disk_gb
  vm_hw_version       = 17
  vm_ip_offset        = var.crdb_client_vm_per_cluster
}
