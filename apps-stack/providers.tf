provider "kubernetes" {
  alias                  = "eks"
  host                   = data.terraform_remote_state.infra.outputs.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infra.outputs.eks_cluster_ca)

  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args        = ["eks", "get-token",
                   "--cluster-name", data.terraform_remote_state.infra.outputs.eks_cluster_name,
                   "--region", var.region]
  }
}

provider "helm" {
  alias = "eks"
  kubernetes = {
    host                   = data.terraform_remote_state.infra.outputs.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.infra.outputs.eks_cluster_ca)
    exec = {
      api_version = "client.authentication.k8s.io/v1"
      command     = "aws"
      args        = ["eks", "get-token",
                     "--cluster-name",data.terraform_remote_state.infra.outputs.eks_cluster_name,
                     "--region", var.region]
    }
  }
}