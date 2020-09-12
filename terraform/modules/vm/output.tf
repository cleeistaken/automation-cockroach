output "vm" {
  value = {
    "name" = "cluster_${var.vsphere_cluster_index + 1}"
    "domain" = var.vsphere_cluster.vs_vm_domain
    "hosts" = vsphere_virtual_machine.vm.*.default_ip_address
    "hostnames" = vsphere_virtual_machine.vm.*.name
  }
}