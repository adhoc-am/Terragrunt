generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  required_version = ">= 1.0.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 2.78.0"
    }
  }
}

provider "azurerm" {
  tenant_id                  = var.tenant_id
  subscription_id            = var.subscription_id
  client_id                  = var.terraform_client_id
  client_secret              = var.terraform_client_secret
  
  skip_provider_registration = true
  features {}
}
EOF
}

remote_state {
  backend = "azurerm"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    key = "${path_relative_to_include()}/terraform.tfstate"
  }
}

terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()

    arguments = [
      "-var-file=../../secrets/azure_access.tfvars"
    ]
  }

  extra_arguments "init_args" {
    commands = [
      "init"
    ]

    arguments = [
      "-backend-config=../../secrets/sa_access.tfvars",
      "-reconfigure"
    ]
  }
}