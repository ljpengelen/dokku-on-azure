variable "production_admin_username" {}
variable "production_subscription_id" {}

provider "azurerm" {
  version = "~> 1.17"
  subscription_id = "${var.production_subscription_id}"
}

module "dokku_on_azure_prd" {
  source = "../modules/dokku_on_azure"

  admin_username = "${var.production_admin_username}"
  env = "production"
  resource_group_name = "eu-production"
}
