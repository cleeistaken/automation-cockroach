resource "local_file" "inventory" {
  content  = templatefile("${path.module}/inventory.yml.tpl", { cockroach = var.cockroach })
  filename = "${var.output_folder}/inventory.yml"
  file_permission = "644"
}
