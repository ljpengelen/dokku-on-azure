variable "staging_admin_username" {}
variable "staging_subscription_id" {}

provider "azurerm" {
  version = "~> 1.17"
  subscription_id = "${var.staging_subscription_id}"
}

module "dokku_on_azure_stg" {
  source = "../modules/dokku_on_azure"

  admin_username = "${var.staging_admin_username}"
  env = "staging"
  resource_group_name = "eu-staging"
}
