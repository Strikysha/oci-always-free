terraform {
  cloud {
    # Replace YOUR_TFC_ORG with your Terraform Cloud organization name
    organization = "Strikysha_org"

    workspaces {
      name = "oci-always-free"
    }
  }
}
