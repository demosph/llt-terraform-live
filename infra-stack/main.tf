# Підключаємо модуль S3 та DynamoDB
module "s3_backend" {
  source      = "../modules/s3-backend"
  bucket_name = "llt-tfstate-bucket"
  table_name  = "terraform-locks"
}

# Підключаємо модуль VPC
module "vpc" {
  source             = "../modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
  vpc_name           = "llt-vpc"
}

# Підключаємо ECR модуль
module "ecr" {
  source = "../modules/ecr"

  # створюємо по модулю на кожну назву
  for_each = toset(var.ecr_repositories)

  ecr_name     = each.value
  scan_on_push = true
}

# Підключаємо модуль EKS
module "eks" {
  source        = "../modules/eks"
  cluster_name  = "eks-cluster-demo"        # Назва кластера
  subnet_ids    = module.vpc.public_subnets # ID підмереж
  instance_type = "t3.small"                # Тип інстансів
  region        = var.region                # Регіон
  desired_size  = 3                         # Бажана кількість нодів
  max_size      = 6                         # Максимальна кількість нодів
  min_size      = 3                         # Мінімальна кількість нодів
  vpc_id        = module.vpc.vpc_id         # VPC ID для ALB Controller

  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }
}

# Підключаємо модуль k8s-baseline
module "k8s_baseline" {
  source = "../modules/k8s-baseline"

  providers = {
    kubernetes = kubernetes.eks
  }

  depends_on = [
    module.eks
  ]
}
