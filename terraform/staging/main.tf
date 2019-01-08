variable "common_computer_name" {}
variable "common_domain_name_label_prefix" {}
variable "common_http_whitelist_port_ranges" {
  type = "list"
}

variable "staging_admin_username" {}
variable "staging_ssh_key" {}
variable "staging_subscription_id" {}

provider "azurerm" {
  version = "~> 1.17"
  subscription_id = "${var.staging_subscription_id}"
}

module "azure_vm_staging" {
  source = "../modules/azure_vm"

  admin_username = "${var.staging_admin_username}"
  computer_name = "${var.common_computer_name}"
  domain_name_label_prefix = "${var.common_domain_name_label_prefix}"
  env = "staging"
  http_whitelist_port_ranges = "${var.common_http_whitelist_port_ranges}"
  resource_group_name = "eu-staging"
  ssh_key_data = "${file(var.staging_ssh_key)}"
}
