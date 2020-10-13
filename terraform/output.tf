output cockroach {
  value = module.cockroach
}

module "inventory" {
  source  = "./modules/inventory"
  cockroach = module.cockroach
  output_folder = "../ansible/"
}
