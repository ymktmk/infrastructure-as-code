# 既にECRへの権限あり
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.15.0"

  cluster_name                   = "eks"
  cluster_version                = "1.21"
  cluster_endpoint_public_access = true

  vpc_id = module.vpc.vpc_id
  # public_subnet
  subnet_ids  = module.vpc.public_subnets
  enable_irsa = true

  eks_managed_node_groups = {
    green = {
      min_size       = 2
      max_size       = 4
      desired_size   = 3
      instance_types = ["t3.large"]
    }
  }

  node_security_group_additional_rules = {
    admission_webhook = {
      description                   = "Admission Webhook"
      protocol                      = "tcp"
      from_port                     = 0
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true
    }

    ingress_node_communications = {
      description = "Ingress Node to node"
      protocol    = "tcp"
      from_port   = 0
      to_port     = 65535
      type        = "ingress"
      self        = true
    }
    egress_node_communications = {
      description      = "Egress Node to node"
      protocol         = "tcp"
      from_port        = 0
      to_port          = 65535
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}
