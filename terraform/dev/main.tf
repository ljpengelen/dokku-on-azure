variable "dev_admin_username" {}
variable "dev_subscription_id" {}

provider "azurerm" {
  version = "~> 1.17"
  subscription_id = "${var.dev_subscription_id}"
}

module "azure_vm_dev" {
  source = "../modules/azure_vm"

  admin_username = "${var.dev_admin_username}"
  env = "dev"
  resource_group_name = "eu-dev"
}
