locals {
  lf_readonly_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Lake Formation handshake
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
        ], Resource = "*" },

      # S3 read data
      { Effect = "Allow", Action = ["s3:GetObject"],
        Resource = "arn:aws:s3:::*" },
      { Effect = "Allow", Action = ["s3:ListBucket"],
        Resource = "arn:aws:s3:::*",
      },

      # Athena query lifecycle + read results
      { Effect = "Allow", Action = [
          "athena:StartQueryExecution","athena:GetQueryExecution",
          "athena:GetQueryResults"
        ], Resource = "*" },
      { Effect = "Allow", Action = ["s3:GetObject"],
        Resource = "arn:aws:s3:::*" }
    ]
  })

  lf_readwrite_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Lake Formation handshake
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
        ], Resource = "*" },

      # S3 read data
      { Effect = "Allow", Action = ["s3:GetObject"],
        Resource = "arn:aws:s3:::*" },
      { Effect = "Allow", Action = ["s3:ListBucket"],
        Resource = "arn:aws:s3:::*"
      },

      # Athena query lifecycle + read results
      { Effect = "Allow", Action = [
          "athena:StartQueryExecution","athena:GetQueryExecution",
          "athena:GetQueryResults"
        ], Resource = "*" },
      { Effect = "Allow", Action = ["s3:GetObject"],
        Resource = "arn:aws:s3:::*" }
    ] + [
      # add write on S3
      { Effect = "Allow", Action = ["s3:PutObject","s3:DeleteObject"],
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*"
        ] },
      { Effect   = "Allow",
        Action   = ["s3:ListBucket"],
        Resource = "arn:aws:s3:::*"
      }
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