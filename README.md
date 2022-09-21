# azure-archive
A place to archive my learning experiences/projects with Microsoft Azure

## bastion-automation-powershell
Uses an Azure Logic App to deploy an Azure Bastion jump box by executing an Azure Resource Manager template deployment when an HTTP request containing "Action: Deploy" is received.
When an HTTP request containing "Action: Delete" is received, the Logic App targets the URI of the Bastion host and deletes it.

Since a Bastion host isn't frequently accessed in most cases, and Azure's pricing for running a Bastion is not cheap, provisioning it only when it is needed saves a lot of money. Additionally, Bastion now supports VNet peering, so a single Bastion is enough to access all my peered resources.


## sapas-infrastructure
![My first attempt at Infrastructure as Code](https://github.com/brandonch-9029/azure-archive/blob/main/img/resourcevisualizer.PNG?raw=true)

My first attempt at defining Infrastructure as Code using Azure's Bicep language. Deploys a set of cloud infrastructure that consists of Staging and Production Virtual Machines and SQL Databases secured behind a Firewall and WAF. Following best practice, all passwords are declared with the Secure() decorator to prevent secrets from being compromised.


