data "aws_caller_identity" "current" {}
locals {

  fin_analysis_db_arn      = "arn:aws:glue:us-east-1:${data.aws_caller_identity.current.account_id}:database/fin_analysis"
  fin_analysis_table_arn   = "arn:aws:glue:us-east-1:${data.aws_caller_identity.current.account_id}:table/fin_analysis/*"
  treas_ops_db_arn      = "arn:aws:glue:us-east-1:${data.aws_caller_identity.current.account_id}:database/treas_ops"
  treas_ops_table_arn   = "arn:aws:glue:us-east-1:${data.aws_caller_identity.current.account_id}:table/treas_ops/*"
  athena_fin_analysis_results_arn  = "arn:aws:s3:::fin_analysis/*"
  athena_treas_ops_results_arn  = "arn:aws:s3:::treas_ops/*"

  lf_readonly_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Lake-Formation handshake
      { Effect = "Allow", Action = [
          "lakeformation:GetDataAccess",
          "lakeformation:GetResourceLFTags",
          "lakeformation:ListLFTags"
        ], Resource = "*" },

      # Glue catalog look‑ups
      { Effect = "Allow", Action = [
          "glue:GetDatabase","glue:GetDatabases",
          "glue:GetTable","glue:GetTables","glue:GetPartitions",
          "glue:SearchTables"
        ], Resource = [
          local.fin_analysis_db_arn,
          local.fin_analysis_table_arn
        ]  },

      # S3 read data
      { "Effect":"Allow",
        "Action": ["s3:ListBucket", "s3:GetBucketLocation"]
        "Resource":"arn:aws:s3:::*",
        "Condition":{ "StringEquals":{
          "     aws:ResourceTag/Data_Classification":"fin_analysis"
              }}
      },
      { "Effect":"Allow",
        "Action":"s3:GetObject",
        "Resource":"arn:aws:s3:::*/*",
        "Condition":{ "StringEquals":{
              "s3:ExistingObjectTag/Data_Classification":"fin_analysis"
              }}
      },

      # Athena query lifecycle + read results
      { Effect = "Allow", Action = [
          "athena:StartQueryExecution","athena:GetQueryExecution",
          "athena:GetQueryResults","athena:StopQueryExecution",
          "athena:ListQueryExecutions"
        ], Resource = "*" },
      { "Effect": "Allow",
        "Action": ["s3:GetObject"],
        "Resource": local.athena_fin_analysis_results_arn }
    ]
  })

  lf_readwrite_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Lake-Formation handshake
      { Effect = "Allow", Action = [
          "lakeformation:GetDataAccess",
          "lakeformation:GetResourceLFTags",
          "lakeformation:ListLFTags"
        ], Resource = "*" },

      # Glue catalog look‑ups
      { Effect = "Allow", Action = [
          "glue:GetDatabase","glue:GetDatabases",
          "glue:GetTable","glue:GetTables","glue:GetPartitions",
          "glue:SearchTables"
        ], Resource = [
          local.treas_ops_db_arn,
          local.treas_ops_table_arn
        ]  },

      # S3 read and write data
      { Effect = "Allow", Action = ["s3:GetObject","s3:ListBucket","s3:PutObject","s3:DeleteObject"],
        Resource = "arn:aws:s3:::*"
        "Condition": { "StringEquals" : { "s3:ResourceTag/Data_Classification" : "treas_ops" }}
      },

      # Athena query lifecycle + read results
      { Effect = "Allow", Action = [
          "athena:StartQueryExecution","athena:GetQueryExecution",
          "athena:GetQueryResults"
        ], Resource = "*" },
      { "Effect": "Allow",
        "Action": ["s3:GetObject"],
        "Resource": local.athena_treas_ops_results_arn }
    ]
  })
}

resource "aws_iam_policy" "lf_readonly" {
  name   = "LakeFormationReadOnly"
  path   = "/"
  policy = local.lf_readonly_json
}

resource "aws_iam_policy" "lf_readwrite" {
  name   = "LakeFormationRawDerivedRW"
  path   = "/"
  policy = local.lf_readwrite_json
}