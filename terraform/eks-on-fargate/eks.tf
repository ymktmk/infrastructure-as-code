# https://qiita.com/dulao5/items/a91d1495300f1bf84878
# 既にECRへの権限あり
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.0"

  cluster_name                   = "eks"
  cluster_version                = "1.21"
  cluster_endpoint_public_access = true

  vpc_id = module.vpc.vpc_id
  # public_subnets or private_subnets
  subnet_ids  = module.vpc.private_subnets
  enable_irsa = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    green = {
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = ["t3.large"]
    }
  }

  # Fargate Profile(s) Private Subnetのみサポート
  fargate_profiles = {
    nginx = {
      name = "nginx"
      selectors = [
        {
          namespace = "nginx"
        }
      ]
    }
  }

  # kubectl get configmap/aws-auth -n kube-system -o yamlで確認
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::009554248005:role/${aws_iam_role.github_actions_oidc.name}"
      username = "github-actions-k8s-access"
      # !!!
      groups   = ["job-exec-group"]
      # groups   = ["system:masters"]
    },
  ]

  # 追加のセキュリティグループ(コントロールプレーンSG)
  # このSGはマネージド型ノードグループのワーカーノード、FargateのPodにはアタッチされない。
  cluster_security_group_additional_rules = {
    ingress_cluster_communications = {
      description                = "Ingress Prometheus"
      protocol                   = "tcp"
      from_port                  = 9292
      to_port                    = 9292
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  # 追加のノードSG
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

# クラスターセキュリティグループ
resource "aws_security_group_rule" "ingress_prometheus_communications_for_fargate" {
  security_group_id = module.eks.cluster_primary_security_group_id
  type              = "ingress"
  from_port         = 9292
  to_port           = 9292
  protocol          = "tcp"
  # 追加のノードSGからFargatePodへの通信を許可する
  source_security_group_id = module.eks.node_security_group_id
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
