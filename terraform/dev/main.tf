variable "common_computer_name" {}
variable "common_domain_name_label_prefix" {}
variable "common_http_whitelist_port_ranges" {
  type = "list"
}

variable "dev_admin_username" {}
variable "dev_ssh_key" {}
variable "dev_subscription_id" {}

provider "azurerm" {
  version = "~> 1.17"
  subscription_id = "${var.dev_subscription_id}"
}

terraform {
  backend "azurerm" {
    container_name = "terraform-state"
    key = "dev.terraform.tfstate"
  }
}

module "azure_vm_dev" {
  source = "../modules/azure_vm"

  admin_username = "${var.dev_admin_username}"
  computer_name = "${var.common_computer_name}"
  domain_name_label_prefix = "${var.common_domain_name_label_prefix}"
  env = "dev"
  http_whitelist_port_ranges = "${var.common_http_whitelist_port_ranges}"
  resource_group_name = "eu-dev"
  ssh_key_data = "${file(var.dev_ssh_key)}"
}
