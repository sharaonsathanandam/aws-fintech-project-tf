provider "aws" {
  alias  = "sso"
  region = "us-east-1"    # Identity Center home Region
}

// Fetch current AWS account and SSO instance info
data "aws_caller_identity" "current" {}

data "aws_ssoadmin_instances" "sso" {
  provider = aws.sso
}

// Lookup Identity Center groups by display name
data "aws_identitystore_group" "finance_analysts-group" {
  provider          = aws.sso
  identity_store_id = tolist(data.aws_ssoadmin_instances.sso.identity_store_ids)[0]
  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = "Financial-Analysts"
    }
  }
}

data "aws_identitystore_group" "treasury-ops-group" {
  provider          = aws.sso
  identity_store_id = tolist(data.aws_ssoadmin_instances.sso.identity_store_ids)[0]
  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = "Treasury-Ops"
    }
  }
}

# // Create SSO Permission Set for Finance Analysts
# resource "aws_ssoadmin_permission_set" "finance_analysts-sso" {
#   provider          = aws.sso
#   name         = "FinanceAnalysts"
#   description  = "Read-only Lake Formation access for Finance Analysts"
#   instance_arn = data.aws_ssoadmin_instances.sso.arns[0]
# }
#
# // Attach AWS managed policy for Lake Formation read access
# resource "aws_ssoadmin_managed_policy_attachment" "finance_analysts" {
#   provider          = aws.sso
#   instance_arn       = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
#   managed_policy_arn = "arn:aws:iam::aws:policy/AWSLakeFormationReadOnlyAccess"
#   permission_set_arn = aws_ssoadmin_permission_set.finance_analysts-sso.arn
# }
#
# // Create SSO Permission Set for Treasury Ops
# resource "aws_ssoadmin_permission_set" "treasury_ops-sso" {
#   provider          = aws.sso
#   name         = "TreasuryOps"
#   description  = "Read/write Lake Formation access for Treasury Ops"
#   instance_arn = data.aws_ssoadmin_instances.sso.arns[0]
# }
# // Attach AWS managed policy for Lake Formation read access
# resource "aws_ssoadmin_managed_policy_attachment" "treasury_ops" {
#   provider          = aws.sso
#   instance_arn       = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
#   managed_policy_arn = "arn:aws:iam::aws:policy/AWSLakeFormationReadOnlyAccess"
#   permission_set_arn = aws_ssoadmin_permission_set.treasury_ops-sso.arn
# }
#
# // Assign Finance Analysts group to their Permission Set in this AWS account
# resource "aws_ssoadmin_account_assignment" "finance_analysts_assignment" {
#   provider          = aws.sso
#   instance_arn       = data.aws_ssoadmin_instances.sso.arns[0]
#   permission_set_arn = aws_ssoadmin_permission_set.finance_analysts-sso.arn
#   principal_type     = "GROUP"
#   principal_id       = data.aws_identitystore_group.finance_analysts-group.group_id
#   target_id          = data.aws_caller_identity.current.account_id
#   target_type        = "AWS_ACCOUNT"
# }
#
# // Assign Treasury Ops group to their Permission Set in this AWS account
# resource "aws_ssoadmin_account_assignment" "treasury_ops_assignment" {
#   provider          = aws.sso
#   instance_arn       = data.aws_ssoadmin_instances.sso.arns[0]
#   permission_set_arn = aws_ssoadmin_permission_set.treasury_ops-sso.arn
#   principal_type     = "GROUP"
#   principal_id       = data.aws_identitystore_group.treasury-ops-group.group_id
#   target_id          = data.aws_caller_identity.current.account_id
#   target_type        = "AWS_ACCOUNT"
# }
