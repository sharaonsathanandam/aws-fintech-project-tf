// Fetch current AWS account and SSO instance info
data "aws_caller_identity" "current" {}

data "aws_ssoadmin_instances" "sso" {}

// Lookup Identity Center groups by display name
data "aws_identitystore_groups" "finance_analysts" {
  identity_store_id = data.aws_ssoadmin_instances.sso.identity_store_ids
  filter {
    attribute_path  = "DisplayName"
    attribute_value = "Financial-Analysts"
  }
}

data "aws_identitystore_groups" "treasury_ops" {
  identity_store_id = data.aws_ssoadmin_instances.sso.identity_store_ids
  filter {
    attribute_path  = "DisplayName"
    attribute_value = "Treasury-Ops"
  }
}

// Create SSO Permission Set for Finance Analysts
resource "aws_ssoadmin_permission_set" "finance_analysts" {
  name               = "FinanceAnalysts"
  description        = "Read-only Lake Formation access for Finance Analysts"
  instance_arn       = data.aws_ssoadmin_instances.sso.arns[0]

  // Attach AWS managed policy for Lake Formation read access
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSLakeFormationReadOnlyAccess"
  ]
}

// Create SSO Permission Set for Treasury Ops
resource "aws_ssoadmin_permission_set" "treasury_ops" {
  name               = "TreasuryOps"
  description        = "Read/write Lake Formation access for Treasury Ops"
  instance_arn       = data.aws_ssoadmin_instances.sso.arns[0]

  // Attach AWS managed policy for Lake Formation admin access
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSLakeFormationReadOnlyAccess"
  ]
}

// Assign Finance Analysts group to their Permission Set in this AWS account
resource "aws_ssoadmin_account_assignment" "finance_analysts_assignment" {
  instance_arn       = data.aws_ssoadmin_instances.sso.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.finance_analysts.arn
  principal_type     = "GROUP"
  principal_id       = data.aws_identitystore_groups.finance_analysts.groups[0].group_id
  target_id          = data.aws_caller_identity.current.account_id
  target_type        = "AWS_ACCOUNT"
}

// Assign Treasury Ops group to their Permission Set in this AWS account
resource "aws_ssoadmin_account_assignment" "treasury_ops_assignment" {
  instance_arn       = data.aws_ssoadmin_instances.sso.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.treasury_ops.arn
  principal_type     = "GROUP"
  principal_id       = data.aws_identitystore_groups.treasury_ops.groups[0].group_id
  target_id          = data.aws_caller_identity.current.account_id
  target_type        = "AWS_ACCOUNT"
}
