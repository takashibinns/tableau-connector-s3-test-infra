
###############################
# Variables & Resource Names  #
###############################

variable "aws_region" {
  description = "What AWS region should we deploy to?"
  type        = string
  default     = "us-west-2"
}
variable "aws_bucket_name" {
  description = "What should we name the S3 bucket?"
  type        = string
  default     = "tableau-s3-connector-data"
}
variable "aws_iam_user_name" {
  description = "Name of an existing IAM User?"
  type        = string
  default     = "AccountS3Connector"
}


#############################
# Create AWS resources      #
#############################

#   Specify the Provider (AWS)
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = "Development"
      Creator     = "tbinns@tableau.com"
      Group       = "tbinns@tableau.com"
      DeptCode    = "429"
      Application = "S3 Connector Testing"
      Description = "Testing resource for Tableau S3 connector"
    }
  }
}

#   Create a new S3 bucket
resource "aws_s3_bucket" "tableau_s3_bucket" {
  bucket = var.aws_bucket_name
  tags   = {
    Name    = "${var.aws_bucket_name}"
  }
}
#   Add CORS permissions for the bucket
resource "aws_s3_bucket_cors_configuration" "tableau_s3_bucket" {
  bucket = aws_s3_bucket.tableau_s3_bucket.bucket
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["*"]
    expose_headers  = ["x-amz-server-side-encryption", "x-amz-request-id", "x-amz-id-2"]
    max_age_seconds = 3000
  }
}

# #   IAM User for connecting from Tableau
# resource "aws_iam_user" "tableau_iam_user" {
#   count = var.aws_iam_user_name != "" ? 1 : 0
#   name  = "Tableau-S3-Connector-User"
#   path  = "/"
# }
# #   Access key for IAM User
# resource "aws_iam_access_key" "tableau_iam_user_access_key" {
#   count   = var.aws_iam_user_name != "" ? 1 : 0
#   user    = aws_iam_user.tableau_iam_user[count.index].name
# }
resource "aws_iam_group" "tableau_iam_group" {
  name = "Tableau-S3-Connector-Group"
  path = "/"
}
resource "aws_iam_group_membership" "tableau_iam_group_membership" {
  name = "Tableau-S3-Connector-Group-Membership"
  users = [ "${var.aws_iam_user_name}"]
  group = aws_iam_group.tableau_iam_group.name
}

#   IAM Policy
resource "aws_iam_policy" "tableau_iam_policy" {
  name        = "Tableau-S3-Connector-Policy"
  path        = "/"
  description = "Allow Tableau to query files in S3 (Tableau S3 Connector)"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.aws_bucket_name}",
          "arn:aws:s3:::${var.aws_bucket_name}/*",
        ]
      }
    ]
  })
}
#   Attach our policies to the IAM role
resource "aws_iam_policy_attachment" "tableau_iam_policy_attachment" {
  name          = "tableau_s3_connector_iam_policy_attachment"
  groups         = [ aws_iam_group.tableau_iam_group.name ]
  policy_arn    = aws_iam_policy.tableau_iam_policy.arn
}

#########################
# Test Data             #
#########################

# Test CSV File
resource "aws_s3_object" "csv" {
  bucket = aws_s3_bucket.tableau_s3_bucket.bucket
  key    = "county-population-health.csv"
  source = "${path.module}/test_data/county-population-health.csv"
  etag   = "${filemd5("${path.module}/test_data/county-population-health.csv")}"
}

# Test Excel file
resource "aws_s3_object" "xlsx" {
  bucket = aws_s3_bucket.tableau_s3_bucket.bucket
  key    = "test_data/SuperstoreHospital.xlsx"
  source = "${path.module}/test_data/SuperstoreHospital.xlsx"
  etag   = "${filemd5("${path.module}/test_data/SuperstoreHospital.xlsx")}"
}

#########################
# Outputs               #
#########################

output "Bucket_Region" {
  value = var.aws_region
}
output "Bucket_Name" {
  value = var.aws_bucket_name
}
# output "Access_Key_ID" {
#   value = aws_iam_access_key.tableau_iam_user_access_key.id
# }
# output "Access_Key_Secret" {
#   value = aws_iam_access_key.tableau_iam_user_access_key.secret
#   sensitive = true
# }