output "vm" {
  value = {
    "cluster_id" = var.vsphere_cluster_index + 1
    "count" = var.vm_count
    "domain" = var.vsphere_cluster.vs_vm_domain
    "ips" = vsphere_virtual_machine.vm.*.default_ip_address
    "hostnames" = vsphere_virtual_machine.vm.*.name
  }
}