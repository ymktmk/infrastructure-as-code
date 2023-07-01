# https://qiita.com/dulao5/items/a91d1495300f1bf84878
# 既にECRへの権限あり
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.0"

  cluster_name                   = "eks"
  cluster_version                = "1.24"
  cluster_endpoint_public_access = true

  vpc_id = module.vpc.vpc_id
  # public_subnets or private_subnets
  subnet_ids  = module.vpc.public_subnets
  enable_irsa = true

  cluster_addons = {
    # https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/managing-coredns.html
    coredns = {
      addon_version     = "v1.9.3-eksbuild.3"
      resolve_conflicts = "OVERWRITE"
    }
    # https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/managing-kube-proxy.html
    kube-proxy = {
      addon_version     = "v1.24.10-eksbuild.2"
      resolve_conflicts = "OVERWRITE"
    }
    # https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/managing-vpc-cni.html
    vpc-cni = {
      addon_version     = "v1.12.6-eksbuild.2"
      resolve_conflicts = "OVERWRITE"
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    green = {
      min_size       = 2
      max_size       = 3
      desired_size   = 3
      instance_types = ["t3.large"]
    }
  }

  # Fargate Profile(s) Private Subnetのみサポート
  # eks-fargate-podというPod実行Roleが作成される
  # fargate_profiles = {
  #   go = {
  #     name = "go"
  #     selectors = [
  #       {
  #         namespace = "go"
  #       }
  #     ]
  #   }

  #   datadog = {
  #     name = "datadog"
  #     selectors = [
  #       {
  #         namespace = "datadog"
  #       }
  #     ]
  #   }

  #   nginx = {
  #     name = "nginx"
  #     selectors = [
  #       {
  #         namespace = "nginx"
  #       }
  #     ]
  #   }

  #   sidekiq = {
  #     name = "sidekiq"
  #     selectors = [
  #       {
  #         namespace = "sidekiq"
  #       }
  #     ]
  #   }
  # }

  # kubectl get configmap/aws-auth -n kube-system -o yamlで確認
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::081151808619:role/${aws_iam_role.github_actions_oidc.name}"
      username = "github-actions-k8s-access"
      # groups   = ["job-exec-group"] <--- 作成したrole-group
      groups = ["system:masters"]
    },
  ]

  # 追加のセキュリティグループ(コントロールプレーンSG)
  # このSGはマネージド型ノードグループのワーカーノード、FargateのPodにはアタッチされない。
  cluster_security_group_additional_rules = {
    ingress_cluster_communications = {
      description                = "Ingress Prometheus"
      protocol                   = "tcp"
      from_port                  = 3000
      to_port                    = 3000
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

# --- EC2に対するSG (coreDNSとの疎通) ----
# Fargate(Pod) -> EC2 
resource "aws_security_group_rule" "ingress_tcp_node_communications_for_fargate" {
  security_group_id        = module.eks.node_security_group_id
  type                     = "ingress"
  from_port                = 53
  to_port                  = 53
  protocol                 = "tcp"
  source_security_group_id = module.eks.cluster_primary_security_group_id
}

resource "aws_security_group_rule" "ingress_udp_node_communications_for_fargate" {
  security_group_id        = module.eks.node_security_group_id
  type                     = "ingress"
  from_port                = 53
  to_port                  = 53
  protocol                 = "udp"
  source_security_group_id = module.eks.cluster_primary_security_group_id
}


# EC2 -> Fargate(Pod)
# resource "aws_security_group_rule" "ingress_prometheus_communications_for_fargate" {
#   security_group_id = module.eks.cluster_primary_security_group_id
#   type              = "ingress"
#   from_port         = 9292
#   to_port           = 9292
#   protocol          = "tcp"
#   # 追加のノードSGからFargatePodへの通信を許可する
#   source_security_group_id = module.eks.node_security_group_id
# }

# --- Podに対するSecurityGroupPolicy ---
# EC2 -> Fargate(Pod)
# resource "aws_security_group" "security_group_policy_for_sidekiq_exporter" {
#   name   = "security_group_policy_for_sidekiq_exporter"
#   vpc_id = module.vpc.vpc_id
# }

# resource "aws_security_group_rule" "accept9292" {
#   security_group_id        = aws_security_group.security_group_policy_for_sidekiq_exporter.id
#   type                     = "ingress"
#   source_security_group_id = module.eks.node_security_group_id
#   from_port                = 9292
#   to_port                  = 9292
#   protocol                 = "tcp"
# }

# resource "aws_security_group_rule" "out_all" {
#   security_group_id = aws_security_group.security_group_policy_for_sidekiq_exporter.id
#   type              = "egress"
#   cidr_blocks       = ["0.0.0.0/0"]
#   from_port         = 0
#   to_port           = 65535
#   protocol          = "-1"
# }
