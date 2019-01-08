variable "admin_username" {}

variable "computer_name" {}

variable "domain_name_label_prefix" {}

variable "env" {}

variable "resource_group_name" {}

variable "ssh_key_data" {}

variable "vm_size" {
  default = "Standard_B1S"
}

variable "http_whitelist_ip_ranges" {
  default = ["0.0.0.0/0"]
}

variable "http_whitelist_port_ranges" {
  default = ["80"]
}

variable "ssh_whitelist_ip_ranges" {
  default = ["212.78.221.106"]
}

data "azurerm_resource_group" "main" {
  name = "${var.resource_group_name}"
}

resource "azurerm_virtual_network" "main" {
  name = "${var.env}-network"
  address_space = ["10.0.0.0/16"]
  location = "${data.azurerm_resource_group.main.location}"
  resource_group_name = "${data.azurerm_resource_group.main.name}"
}

resource "azurerm_subnet" "main" {
  name = "${var.env}-subnet"
  resource_group_name = "${data.azurerm_resource_group.main.name}"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  address_prefix = "10.0.2.0/24"
}

resource "azurerm_public_ip" "main" {
  name = "${var.env}-public-ip"
  location = "${data.azurerm_resource_group.main.location}"
  resource_group_name = "${data.azurerm_resource_group.main.name}"
  public_ip_address_allocation = "static"
  domain_name_label = "${var.domain_name_label_prefix}-${var.env}"
}

resource "azurerm_network_security_group" "main" {
  name = "${var.env}-security-group"
  location = "${data.azurerm_resource_group.main.location}"
  resource_group_name = "${data.azurerm_resource_group.main.name}"

  security_rule {
    name = "ssh"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefixes = "${var.ssh_whitelist_ip_ranges}"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "http"
    priority = 200
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_ranges = "${var.http_whitelist_port_ranges}"
    source_address_prefixes = "${var.http_whitelist_ip_ranges}"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "main" {
  name = "${var.env}-network-interface"
  location = "${data.azurerm_resource_group.main.location}"
  resource_group_name = "${data.azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"

  ip_configuration {
    name = "${var.env}-ip-configuration"
    subnet_id = "${azurerm_subnet.main.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = "${azurerm_public_ip.main.id}"
  }
}

resource "azurerm_virtual_machine" "main" {
  name = "${var.env}-virtual-machine"
  location = "${data.azurerm_resource_group.main.location}"
  resource_group_name = "${data.azurerm_resource_group.main.name}"
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size = "${var.vm_size}"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name= "${var.env}-os-disk"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name = "${var.env}-${var.computer_name}"
    admin_username = "${var.admin_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = "${var.ssh_key_data}"
      path = "/home/${var.admin_username}/.ssh/authorized_keys"
    }
  }
}
