resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Role for GitHub Actions
locals {
  # Build allowed subjects for GitHub repos and ref patterns
  github_subs = flatten([
    for repo in var.github_repositories : [
      for refp in var.github_ref_patterns : "repo:${repo}:${refp}"
    ]
  ])

  # If no ECR repositories specified, allow all ("*"), else build ARNs
  ecr_repo_arns = var.ecr_repositories == null ? ["*"] : [
        for name in var.ecr_repositories :
        "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/${name}"
      ]
}

resource "aws_iam_role" "github_ecr_push" {
  name = "github-ecr-push"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        },
        # Allow only specified repositories and ref patterns
        StringLike = {
          "token.actions.githubusercontent.com:sub" = local.github_subs
        }
      }
    }]
  })
}

resource "aws_iam_policy" "ecr_push" {
  name = "GithubEcrPushPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # ECR authorization token for push/pull
      {
        Effect   = "Allow",
        Action   = ["ecr:GetAuthorizationToken"],
        Resource = "*"
      },
      # push/pull shardes to specified repositories
      {
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:BatchGetImage",
          "ecr:DescribeRepositories",
          "ecr:ListImages"
        ],
        Resource = local.ecr_repo_arns
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.github_ecr_push.name
  policy_arn = aws_iam_policy.ecr_push.arn
}