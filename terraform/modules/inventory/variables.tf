variable "crdb_servers" {
  type = map
  default = {}
  description = "A map of inventory group names to IP addresses."
}

variable "crdb_client_servers" {
  type = map
  default = {}
  description = "A map of inventory group names to IP addresses."
}

variable "output_folder" {
  type = string
  description = "The path to use when saving the rendered inventory file."
}
