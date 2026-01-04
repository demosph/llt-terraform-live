locals {
  oidc_provider_issuer = replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")
}

data "aws_caller_identity" "current" {}

# SSM read policy
data "aws_iam_policy_document" "eso_read" {
  statement {
    sid     = "SSMRead"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
      "ssm:DescribeParameters"
    ]
    resources = [
      "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/*"
    ]
  }
}

resource "kubernetes_namespace_v1" "eso" {
  metadata {
    name = var.eso_namespace
  }
  depends_on = [aws_eks_cluster.eks]
}

resource "aws_iam_policy" "eso_read" {
  name        = "${var.cluster_name}-eso-read"
  description = "Read-only ESO access"
  policy      = data.aws_iam_policy_document.eso_read.json
}

# IRSA for ServiceAccount: system:serviceaccount:<ns>:<sa>
data "aws_iam_policy_document" "eso_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.oidc.arn
      ]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_issuer}:sub"
      values   = ["system:serviceaccount:${var.eso_namespace}:${var.eso_service_account_name}"]
    }
  }
  depends_on = [
    aws_iam_openid_connect_provider.oidc
  ]
}

resource "aws_iam_role" "eso_irsa_role" {
  name               = "${var.cluster_name}-eso-irsa-role"
  assume_role_policy = data.aws_iam_policy_document.eso_assume.json
}

resource "aws_iam_role_policy_attachment" "eso_irsa_attach" {
  role       = aws_iam_role.eso_irsa_role.name
  policy_arn = aws_iam_policy.eso_read.arn
}

# Configure ESO

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  namespace  = var.eso_namespace
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.19.2"

  # Install CRDs and chart's service account
  set = [
    {
      name  = "installCRDs"
      value = true
    },
    {
      name  = "serviceAccount.create"
      value = true
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.eso_irsa_role.arn
    }
  ]

  depends_on = [
    kubernetes_namespace_v1.eso,
    aws_iam_role.eso_irsa_role
  ]
}
