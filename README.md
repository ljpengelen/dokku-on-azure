# Dokku on Azure

This repository contains a [Terraform](https://www.terraform.io/) configuration and an [Ansible](https://www.ansible.com/) playbook to set up a VM running Dokku on [Microsoft Azure](https://azure.microsoft.com/).

## Installing dependencies

1. Install [Terraform](https://www.terraform.io/), a tool for managing infrastructure as code.
  On macOS, you can install Terraform with [brew](https://brew.sh/): `brew install terraform`.
1. Install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
  If you use brew, execute `brew install azure-cli`.
1. Create an [Azure account](https://azure.microsoft.com/) if you don't have one already.
  Experimenting with the code in this repository will cost you next to nothing.
1. Install [Ansible](https://www.ansible.com/).
  If you use brew, execute `brew install ansible`.

## Creating resources on Azure

1. Log in to Azure by executing `az login` and following the instructions.
  After logging in, you'll see a list of subscriptions associated to your Azure account.
  If you want to use a different subscription for each of the environments, log in to the [Azure Portal](https://portal.azure.com/) and create additional subscriptions.
  If you do so, you can easily see how much each environment costs.
  However, using the same subscription for each environment is also fine.
1. Log in to the [Azure Portal](https://portal.azure.com/) and create a resource group for each of the environments.
  The name of the resource group used for the development environment should be named `eu-dev`.
  This name is used in the file `terraform/dev/main.tf`.
  Similarly, the resource group for staging should be named `eu-staging`, which is used in `terraform/staging/main.tf`,
  and the resource group for production should be named `eu-production`, which is used in `terraform/production/main.tf`.
  Make sure that the resource group you create for a given environment is part of the subscription for that environment.
1. In the Azure Portal, create one or more storage accounts.
  Blobs stored in Azure storage accounts can be used by Terraform to store the state of the infrastructure it manages.
  By storing this state online, it can be shared by multiple developers.
  You could use a separate storage account for each environment, but a single one works fine too.
  Within each of the storage accounts, create a blob container.
1. Create the SSH key pairs to access the VMs as administrator.
  You can create a single key pair for all environments or a separate pair for each environment.
  To generate an RSA key pair with a key size of 4096 bits named `~/.ssh/azure_dokku_admin.pub` and `~/.ssh/azure_dokku_admin` with `ssh-keygen`, execute `ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_dokku_admin`.
1. Create a file called `secrets.tfvars` in the `terraform` folder.
  The file `secrets.example.tfvars` indicates for which variables you need to provide values.
    * Choose usernames that meet [Azure's password complexity requirements](https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html#admin_username).
    * Refer to the public keys of the SSH key pairs you generated in the previous step.
    * Update the subscription identifiers for each of the environments such that they correspond to one of the subscriptions associated to your Azure account.
1. Create files called `backend.tfvars` in the folders `terraform/dev`, `terraform/staging`, and `terraform/production`.
  The files `backend.example.tfvars` indicates for which variables you need to provide values.
  Refer to the name and access keys of the storage account you created for the given environment in one of the previous steps.
1. Enter the folder `terraform`.
1. Enter the folder for the environment you'd like to set up, either `dev`, `staging`, or `production`.
1. Execute `terraform init -backend-config=backend.tfvars`.
1. Execute `terraform apply -var-file=../secrets.tfvars -var-file=../common.tfvars`.

After completing all the steps above for a given environment, you've set up a virtual machine running Ubuntu on Microsoft Azure that is publicly accessible via HTTP on ports 80 and 8000 and via SSH from a single IP address.

Once you're done with your experiments, you can clean up by running `terraform destroy -var-file=../secrets.tfvars -var-file=../common.tfvars`.

## Setting up Dokku

1. Configure SSH to use the administrator keys you created above to access the VMs.
For example, add the following to the file `~/.ssh/config` for the `dev` environment, assuming you've named the SSH key pair for this environment `azure_dokku_dev_admin`.
  ```
  Host kabisa-dokku-demo-dev.westeurope.cloudapp.azure.com
    IdentityFile ~/.ssh/azure_dokku_admin_dev
  ```
1. After creating the resources on Azure and configuring SSH, verify that you can log in to the created VMs via SSH.
1. Create the SSH key pairs to access the Git repositories managed by Dokku.
  You can create a single key pair for all environments or a separate pair for each environment.
  If you only want to deploy to each environment from a single machine, such as an instance of [Jenkins](https://jenkins.io/), a single key is fine.
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
