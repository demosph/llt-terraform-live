locals {
  lbc_namespace       = "kube-system"
  lbc_service_account = "aws-load-balancer-controller"
}

data "http" "aws_load_balancer_controller_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "${var.cluster_name}-aws-load-balancer-controller"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = data.http.aws_load_balancer_controller_iam_policy.response_body
}

# 2) IAM Role (IRSA)
data "aws_iam_policy_document" "aws_load_balancer_controller_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.oidc.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_issuer}:sub"
      values   = ["system:serviceaccount:${local.lbc_namespace}:${local.lbc_service_account}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_issuer}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }

  depends_on = [aws_iam_openid_connect_provider.oidc]
}

resource "aws_iam_role" "aws_load_balancer_controller_irsa_role" {
  name               = "${var.cluster_name}-aws-load-balancer-controller"
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume.json
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_attach" {
  role       = aws_iam_role.aws_load_balancer_controller_irsa_role.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}

# 3) Kubernetes ServiceAccount (створюємо ми, Helm'у кажемо create=false)
resource "kubernetes_service_account_v1" "aws_load_balancer_controller" {
  metadata {
    name      = local.lbc_service_account
    namespace = local.lbc_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_load_balancer_controller_irsa_role.arn
    }
  }

  depends_on = [
    aws_eks_cluster.eks,
    aws_iam_role_policy_attachment.aws_load_balancer_controller_attach
  ]
}

# 4) Helm install AWS Load Balancer Controller
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = local.lbc_namespace
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  values = [
    yamlencode({
      clusterName = aws_eks_cluster.eks.name
      region      = var.region
      vpcId       = var.vpc_id

      ingressClass = "alb"

      serviceAccount = {
        create = false
        name   = local.lbc_service_account
      }
    })
  ]

  depends_on = [
    kubernetes_service_account_v1.aws_load_balancer_controller,
    aws_eks_node_group.general
  ]
}
