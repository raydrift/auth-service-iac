# Local values
locals {
  common_tags = merge(
    {
      Application  = var.application_name
      Environment  = var.environment
      ManagedBy    = "Terraform"
      CreatedDate  = timestamp()
      Owner        = "Erika Rivera"
      Compliance   = "HIPAA"
      CostCenter   = "engineering"
    },
    var.tags
  )
}
