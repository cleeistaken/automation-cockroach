variable "cockroach" {
  description = "A map of CRDB VM."
}

variable "output_folder" {
  description = "The path to use when saving the rendered inventory file."
  type = string
}
