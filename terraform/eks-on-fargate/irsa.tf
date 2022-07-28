module "iam_assumable_role_with_oidc_external_secrets" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 4"

  create_role = true
  role_name   = "oidc-external-secrets"
  tags = {
    Role = "role-with-oidc"
  }
  provider_url = module.eks.cluster_oidc_issuer_url
  role_policy_arns = [
    module.iam_policy_external_secrets.arn,
  ]
  number_of_role_policy_arns = 1
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:default:external-secrets",
  ]
}

module "iam_policy_external_secrets" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 4"

  name        = "external-secrets"
  path        = "/"
  description = "for external secrets"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        "Resource" : [
          "arn:aws:secretsmanager:ap-northeast-1:009554248005:secret:aws/*",
        ],
      }
    ]
  })
}
