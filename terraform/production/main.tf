variable "production_admin_username" {}
variable "production_ssh_key" {}
variable "production_subscription_id" {}

provider "azurerm" {
  version = "~> 1.17"
  subscription_id = "${var.production_subscription_id}"
}

module "azure_vm_production" {
  source = "../modules/azure_vm"

  admin_username = "${var.production_admin_username}"
  computer_name = "dokku"
  domain_name_label_prefix = "kabisa-dokku-demo"
  env = "production"
  http-whitelist-port-ranges = ["80", "8000"]
  resource_group_name = "eu-production"
  ssh_key_data = "${file(var.production_ssh_key)}"
}
