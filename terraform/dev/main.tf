variable "dev_admin_username" {}
variable "dev_subscription_id" {}

provider "azurerm" {
  version = "~> 1.17"
  subscription_id = "${var.dev_subscription_id}"
}

module "dokku_on_azure_dev" {
  source = "../modules/dokku_on_azure"

  admin_username = "${var.dev_admin_username}"
  env = "dev"
  resource_group_name = "eu-dev"
  vm_size = "Standard_B1S"
}
