resource "local_file" "inventory" {
  content  = templatefile("${path.module}/inventory.yml.tpl", { crdb_servers = var.crdb_servers, crdb_client_servers = var.crdb_client_servers })
  filename = "${var.output_folder}/inventory.yml"
  file_permission = "644"
}
