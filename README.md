# tf_assessment

# Overview
Provider configuration: The provider block specifies the Azure provider and its configuration.

Resource Group: The azurerm_resource_group resource creates an Azure resource group to contain all other resources.

Virtual Network: The azurerm_virtual_network and azurerm_subnet resources create an Azure virtual network and a subnet within that virtual network, respectively.

Network Interface: The azurerm_network_interface resource creates an Azure network interface for each VM.

Random Password: The random_password resource generates a random password for each VM's administrator account.

Virtual Machine: The azurerm_linux_virtual_machine resource creates an Azure virtual machine for each network interface, using the specified image and size.

Network Security Group: The azurerm_network_security_group resource creates an Azure network security group to allow incoming SSH traffic.

NSG Association: The azurerm_network_interface_security_group_association resource associates each network interface with the network security group.

Public IP: The azurerm_public_ip resource creates a dynamic public IP address for each virtual machine.

Output: The output block aggregates the results of the ping test between each virtual machine in the format of [source_vm_index, destination_vm_index, ping_result].

Overall, the code creates a configurable number of Azure virtual machines with unique admin passwords, residing in the same virtual network, and able to ping each other in a round-robin fashion. The results of the ping test are then aggregated into a Terraform output variable.

# Prerequisites
Terraform v1.3.7
Azure CLI v2.48.1


# Deploying
Install Terraform: If you haven't already, you'll need to install Terraform on your machine. You can download it from the official website: https://www.terraform.io/downloads.html

Create an Azure account: You'll need an Azure account to be able to create resources on Azure. If you don't have one already, you can sign up for a free trial account here: https://azure.microsoft.com/en-us/free/

Clone the repository on your local machine.

Authenthicate to Azure wth az login.

Initialize the terraform environment with terraform init.

Plan the changes with terraform plan.

Apply the changes with terraform apply.
