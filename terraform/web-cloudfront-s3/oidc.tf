resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_actions_oidc" {
  name = "GitHubActions-OIDC"
  # 信頼関係
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : aws_iam_openid_connect_provider.github_actions.arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          },
          "StringLike" : {
            "token.actions.githubusercontent.com:sub" : "repo:ymktmk/infrastructure-as-code:*"
          },
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_oidc" {
  name = "GitHubActions-OIDC-IAM-Policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : [
          "${aws_s3_bucket.frontend.arn}",
          "${aws_s3_bucket.frontend.arn}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "cloudfront:GetDistribution",
          "cloudfront:GetDistributionConfig",
          "cloudfront:ListDistributions",
          "cloudfront:ListStreamingDistributions",
          "cloudfront:CreateInvalidation",
          "cloudfront:ListInvalidations",
          "cloudfront:GetInvalidation"
        ],
        "Resource" : "${aws_cloudfront_origin_access_identity.origin_access.iam_arn}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_oidc" {
  role       = aws_iam_role.github_actions_oidc.name
  policy_arn = aws_iam_policy.github_actions_oidc.arn
}
