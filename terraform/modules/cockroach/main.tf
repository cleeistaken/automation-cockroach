#
# Cluster
#
data "vsphere_datacenter" "vs_dc" {
  name = var.vsphere_cluster.vs_dc
}

data "vsphere_compute_cluster" "vs_cc" {
  name = var.vsphere_cluster.vs_cls
  datacenter_id = data.vsphere_datacenter.vs_dc.id
}

resource "vsphere_resource_pool" "vs_rp" {
  name = var.vsphere_cluster.vs_rp
  parent_resource_pool_id = data.vsphere_compute_cluster.vs_cc.resource_pool_id
}

data "vsphere_datastore" "vs_ds" {
  name = var.vsphere_cluster.vs_ds
  datacenter_id = data.vsphere_datacenter.vs_dc.id
}

data "vsphere_storage_policy" "vs_ds_policy" {
  name = var.vsphere_cluster.vs_ds_sp
}

data "vsphere_distributed_virtual_switch" "vs_dvs" {
  name = var.vsphere_cluster.vs_dvs
  datacenter_id = data.vsphere_datacenter.vs_dc.id
}

data "vsphere_network" "vs_dvs_pg_1" {
  name = var.vsphere_cluster.vs_dvs_pg_1
  datacenter_id = data.vsphere_datacenter.vs_dc.id
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.vs_dvs.id
}

data "vsphere_virtual_machine" "vs_vm_template" {
  name = var.vsphere_cluster.vs_vm_template
  datacenter_id = data.vsphere_datacenter.vs_dc.id
}

#
# CRDB Client
#

locals {
  crdb_client_prefix = format("%s-%02d", var.crdb_client_name_prefix, (var.vsphere_cluster_index + 1))
  crdb_client_ip_offset = 0
}

resource "vsphere_virtual_machine" "crdb_client_vm" {
  count = var.crdb_client_vm_per_cluster

  name = format("%s-%02d", local.crdb_client_prefix, (count.index + 1))
  guest_id = data.vsphere_virtual_machine.vs_vm_template.guest_id
  hardware_version = var.crdb_client.hw_version

  # Template boot mode (efi or bios)
  firmware = var.vsphere_cluster.vs_vm_template_boot

  # Resource Pool
  resource_pool_id = vsphere_resource_pool.vs_rp.id

  # Home Storage
  datastore_id = data.vsphere_datastore.vs_ds.id
  storage_policy_id = data.vsphere_storage_policy.vs_ds_policy.id

  # Hardware Configuration
  num_cpus = var.crdb_client.cpu_count
  memory = var.crdb_client.memory_gb * 1024

  # Although it is possible to add multiple disk controllers, there is
  # no way as of v0.13 to assign a disk to a controller. All disks are
  # defaulted to the first controller.
  #scsi_controller_count = min (4, (var.vm_data_disk_count + 1))

  network_interface {
    network_id = data.vsphere_network.vs_dvs_pg_1.id
  }

  disk {
    label = format("%s-%02d-os-disk00", local.crdb_client_prefix, (count.index + 1))
    size = var.crdb_client.os_disk_gb
    storage_policy_id = data.vsphere_storage_policy.vs_ds_policy.id
    unit_number = 0
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.vs_vm_template.id

    customize {
      linux_options {
        host_name = format("%s-%02d", local.crdb_client_prefix, count.index + 1)
        domain = var.vsphere_cluster.vs_vm_domain
      }

      network_interface {
        ipv4_address = var.vsphere_cluster.vs_dvs_pg_1_ipv4_ips[(local.crdb_client_ip_offset + count.index)]
        ipv4_netmask = regex("/([0-9]{1,2})$", var.vsphere_cluster.vs_dvs_pg_1_ipv4_subnet)[0]
      }

      ipv4_gateway = var.vsphere_cluster.vs_dvs_pg_1_ipv4_gw
      dns_server_list = var.vsphere_cluster.vs_vm_dns
      dns_suffix_list = var.vsphere_cluster.vs_vm_dns_suffix
    }
  }
}

# CRDB Client Anti-affinity rules
resource "vsphere_compute_cluster_vm_anti_affinity_rule" "crdb_client_anti_affinity_rule" {
  count = var.crdb_client_vm_anti_affinity ? 1 : 0
  name                = format("%s-anti-affinity-rule", var.crdb_client_name_prefix)
  compute_cluster_id  = data.vsphere_compute_cluster.vs_cc.id
  virtual_machine_ids = vsphere_virtual_machine.crdb_client_vm.*.id
}

#
# CRDB
#

locals {
  crdb_prefix = format("%s-%02d", var.crdb_name_prefix, (var.vsphere_cluster_index + 1))
  crdb_ip_offset = local.crdb_client_ip_offset + var.crdb_client_vm_per_cluster
}

resource "vsphere_virtual_machine" "crdb_vm" {
  count = var.crdb_vm_per_cluster

  name = format("%s-%02d", local.crdb_prefix, (count.index + 1))
  guest_id = data.vsphere_virtual_machine.vs_vm_template.guest_id
  hardware_version = var.crdb.hw_version

  # Template boot mode (efi or bios)
  firmware = var.vsphere_cluster.vs_vm_template_boot

  # Resource Pool
  resource_pool_id = vsphere_resource_pool.vs_rp.id

  # Home Storage
  datastore_id = data.vsphere_datastore.vs_ds.id
  storage_policy_id = data.vsphere_storage_policy.vs_ds_policy.id

  # Hardware Configuration
  num_cpus = var.crdb.cpu_count
  memory = var.crdb.memory_gb * 1024

  # Although it is possible to add multiple disk controllers, there is
  # no way as of v0.13 to assign a disk to a controller. All disks are
  # defaulted to the first controller.
  #scsi_controller_count = min (4, (var.vm_data_disk_count + 1))

  network_interface {
    network_id = data.vsphere_network.vs_dvs_pg_1.id
  }

  disk {
    label = format("%s-%02d-os-disk00", local.crdb_prefix, (count.index + 1))
    size = var.crdb.os_disk_gb
    storage_policy_id = data.vsphere_storage_policy.vs_ds_policy.id
    unit_number = 0
  }

  dynamic "disk" {
    for_each = range(1, var.crdb.data_disk_count + 1)

    content {
      label = format("%s-%02d-data-disk%02d", local.crdb_prefix, (count.index + 1), disk.value)
      size = var.crdb.data_disk_gb
      storage_policy_id = data.vsphere_storage_policy.vs_ds_policy.id
      unit_number = disk.value
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.vs_vm_template.id

    customize {
      linux_options {
        host_name = format("%s-%02d", local.crdb_prefix, (count.index + 1))
        domain = var.vsphere_cluster.vs_vm_domain
      }

      network_interface {
        ipv4_address = var.vsphere_cluster.vs_dvs_pg_1_ipv4_ips[(local.crdb_ip_offset + count.index)]
        ipv4_netmask = regex("/([0-9]{1,2})$", var.vsphere_cluster.vs_dvs_pg_1_ipv4_subnet)[0]
      }

      ipv4_gateway = var.vsphere_cluster.vs_dvs_pg_1_ipv4_gw
      dns_server_list = var.vsphere_cluster.vs_vm_dns
      dns_suffix_list = var.vsphere_cluster.vs_vm_dns_suffix
    }
  }
}

# CRDB Anti-affinity rules
resource "vsphere_compute_cluster_vm_anti_affinity_rule" "crdb_anti_affinity_rule" {
  count = var.crdb_vm_anti_affinity ? 1 : 0
  name                = format("%s-anti-affinity-rule", var.crdb_name_prefix)
  compute_cluster_id  = data.vsphere_compute_cluster.vs_cc.id
  virtual_machine_ids = vsphere_virtual_machine.crdb_vm.*.id
}
