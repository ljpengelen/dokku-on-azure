variable "production_admin_username" {}
variable "production_subscription_id" {}

provider "azurerm" {
  version = "~> 1.17"
  subscription_id = "${var.production_subscription_id}"
}

module "azure_vm_production" {
  source = "../modules/azure_vm"

  admin_username = "${var.production_admin_username}"
  env = "production"
  resource_group_name = "eu-production"
}
