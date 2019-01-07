variable "staging_admin_username" {}
variable "staging_subscription_id" {}

provider "azurerm" {
  version = "~> 1.17"
  subscription_id = "${var.staging_subscription_id}"
}

module "azure_vm_staging" {
  source = "../modules/azure_vm"

  admin_username = "${var.staging_admin_username}"
  env = "staging"
  resource_group_name = "eu-staging"
}
