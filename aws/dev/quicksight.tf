resource "aws_iam_role" "quicksight" {
  name = "${local.global_name}-quicksight"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : { "Service" : "quicksight.amazonaws.com" },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "quicskight-athena" {
  role       = aws_iam_role.quicksight.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSQuicksightAthenaAccess"
}

resource "aws_iam_role_policy_attachment" "quicskight-s3" {
  role       = aws_iam_role.quicksight.name
  policy_arn = aws_iam_policy.quicksight-s3.arn
}

resource "aws_iam_policy" "quicksight-s3" {
  name        = "${local.global_name}-quicksight"
  path        = "/"
  description = "Policy for the QuickSight"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid : "IAM",
        Effect : "Allow",
        Action : [
          "iam:List*"
        ],
        Resource : "*",
      },
      {
        Sid : "s3ListAllMyBuckets",
        Effect : "Allow",
        Action : [
          "s3:ListAllMyBuckets"
        ],
        Resource : "arn:aws:s3:::*",
      },
      {
        Sid : "s3ListBucket",
        Effect : "Allow",
        Action : [
          "s3:ListBucket"
        ],
        Resource : "arn:aws:s3:::${module.AWS-deployApp.raw_output_bucket_id}"
      },
      {
        Sid : "s3Object",
        Effect : "Allow",
        Action : [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ],
        Resource : "arn:aws:s3:::${module.AWS-deployApp.raw_output_bucket_id}/*"
      }
    ]
  })
}
