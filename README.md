# Dokku on Azure

This repository contains a [Terraform](https://www.terraform.io/) configuration and an [Ansible](https://www.ansible.com/) playbook to set up a VM running Dokku on [Microsoft Azure](https://azure.microsoft.com/).

## Getting Started

1. Install [Terraform](https://www.terraform.io/), a tool for managing infrastructure as code.
  On macOS, you can install Terraform with [brew](https://brew.sh/): `brew install terraform`.
1. Install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
  On macOS, you can install the Azure CLI with brew: `brew install azure-cli`.
1. Create an [Azure account](https://azure.microsoft.com/) if you don't have one already.
1. Create the SSH keys to access the VMs as administrator and store them in `~/.ssh/azure_dokku_admin.pub` and `~/.ssh/azure_dokku_admin`.
  To generate RSA keys with a key size of 4096 bits, execute `ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_dokku_admin`.
1. Configure SSH to use the administrator keys mentioned above to access the VMs.
1. Create the SSH keys to access the Git repositories managed by Dokku and store them in `~/.ssh/azure_dokku_git.pub` and `~/.ssh/azure_dokku_git`.
  To generate RSA keys with a key size of 4096 bits, execute `ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_dokku_git`.
1. Obtain the files `terraform/secrets.tfvars` and `ansible/secrets.yml`, containing the username for the administrator account.
  Alternatively, create new files containing a username that meets [Azure's password complexity requirements](https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html#admin_username).
1. Install [Ansible](https://www.ansible.com/).
  On macOS, you can install Ansible with brew: `brew install ansible`.

## Creating resources on Azure

1. Log in to Azure by executing `az login` and following the instructions.
  After logging in, you'll see a list of subscriptions associated to your Azure account.
  Instruct Azure to use the subscription for which you'd like to set up or update the infrastructure by executing `az account set --subscription="SUBSCRIPTION_ID"`.
1. Enter the folder `terraform`.
1. Enter the folder for the environment you'd like to set up, either `dev`, `staging`, or `production`.
1. Execute `terraform init`.
1. Execute `terraform apply -var-file=../secrets.tfvars`.

## Setting up Dokku

1. After creating the resources on Azure, verify that you can log in to the created VM via SSH.
  The username is specified in the secret files mentioned above.
  The SSH keys are also listed above.
1. Enter the folder `ansible`.
1. Execute `ansible-playbook -i <environment> -e @secrets.yml dokku.yml` to set up Dokku, where `<environment>` should be one of `dev`, `staging`, and `production`.

## Giving Jenkins access to Dokku repositories

After setting up Dokku, you need to ensure that Jenkins is able to access the Git repositories managed by Dokku.

1. Log in to the machine running Jenkins.
1. Clone the repository for the front-end to a temporary folder by executing `git clone dokku@kabisa-dokku-demo-<env>.westeurope.cloudapp.azure.com:front-end /tmp/deploy-front-end`, where `<env>` is one of `dev`, `staging`, and `production`.

If this succeeds without any errors, Jenkins is able to access the Git repositories managed by Dokku.
If not, one or more of the following issues must be resolved.

* If you see an error regarding host key verification, ensure that the new host key is correct and add it to the `known_hosts` configuration file for SSH.
* If you see a warning stating that the authenticity of the host cannot be established, ensure that the host key is correct and continue connecting.
* If permission to read the repository is denied, update the configuration of SSH to use the correct key.
