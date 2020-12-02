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
# Cockroach
#
module "cockroach" {
  source = "./modules/cockroach"
  count = length(var.vsphere_clusters)

  # vSphere Cluster
  vsphere_cluster_index = count.index
  vsphere_cluster = var.vsphere_clusters[count.index]

  # CRDB Client
  crdb_client_vm_per_cluster = var.crdb_client_vm_per_cluster
  crdb_client_name_prefix = var.crdb_client_name_prefix
  crdb_client_vm_anti_affinity = var.crdb_client_vm_anti_affinity
  crdb_client = var.crdb_client

  # CRDB HA Proxy
  crdb_haproxy_vm_per_cluster = var.crdb_haproxy_vm_per_cluster
  crdb_haproxy_name_prefix = var.crdb_haproxy_name_prefix
  crdb_haproxy_vm_anti_affinity = var.crdb_haproxy_vm_anti_affinity
  crdb_haproxy = var.crdb_haproxy

  # CRDB
  crdb_vm_per_cluster = var.crdb_vm_per_cluster
  crdb_name_prefix = var.crdb_name_prefix
  crdb_vm_anti_affinity = var.crdb_vm_anti_affinity
  crdb = var.crdb
}
