variable "common_computer_name" {}
variable "common_domain_name_label_prefix" {}
variable "common_http_whitelist_port_ranges" {
  type = "list"
}

variable "production_admin_username" {}
variable "production_ssh_key" {}
variable "production_subscription_id" {}

provider "azurerm" {
  version = "~> 1.17"
  subscription_id = "${var.production_subscription_id}"
}

terraform {
  backend "azurerm" {
    container_name = "terraform-state"
    key = "production.terraform.tfstate"
  }
}

module "azure_vm_production" {
  source = "../modules/azure_vm"

  admin_username = "${var.production_admin_username}"
  computer_name = "${var.common_computer_name}"
  domain_name_label_prefix = "${var.common_domain_name_label_prefix}"
  env = "production"
  http_whitelist_port_ranges = "${var.common_http_whitelist_port_ranges}"
  resource_group_name = "eu-production"
  ssh_key_data = "${file(var.production_ssh_key)}"
}
