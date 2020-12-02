output "cockroach" {
  value = {
    "cluster_id" = var.vsphere_cluster_index + 1
    "cluster" = {
      "crdb_client" = vsphere_virtual_machine.crdb_client_vm
      "crdb_haproxy" = vsphere_virtual_machine.crdb_haproxy_vm
      "crdb" = vsphere_virtual_machine.crdb_vm
    }
  }
}
