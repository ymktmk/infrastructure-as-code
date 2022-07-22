# VPC
resource "aws_vpc" "vpc" {
    cidr_block                       = "10.0.0.0/16"
    enable_dns_hostnames             = true
    enable_dns_support               = true
    instance_tenancy                 = "default"
    tags                             = {
        "Name" = "vpc"
    }
}

# パブリックサブネット
resource "aws_subnet" "public_subnet" {
    availability_zone               = "ap-northeast-1a"
    cidr_block                      = "10.0.0.0/24"
    # サブネットで起動したインスタンスにパブリックIPを許可する
    map_public_ip_on_launch = true
    tags                            = {
        "Name" = "public-subnet"
    }
    vpc_id                          = aws_vpc.vpc.id
}

# プライベートサブネット
resource "aws_subnet" "private_subnet" {
    availability_zone               = "ap-northeast-1a"
    cidr_block                      = "10.0.1.0/24"
    # いるかいらんか
    map_public_ip_on_launch = true
    tags                            = {
        "Name" = "private-subnet"
    }
    vpc_id                          = aws_vpc.vpc.id
}

# インターネットゲートウェイ
resource "aws_internet_gateway" "igw" {
    tags     = {
        "Name" = "internet-gateway"
    }
    vpc_id   = aws_vpc.vpc.id
}

# パブリックサブネット用のルートテーブル
resource "aws_route_table" "public_subnet_route_table" {
    route {
        cidr_block                 = "0.0.0.0/0"
        gateway_id                 = aws_internet_gateway.igw.id
    }
    tags             = {
        "Name" = "public-subnet-route-table"
    }
    vpc_id           = aws_vpc.vpc.id
}

# プライベートサブネット用のルートテーブル
resource "aws_route_table" "private_subnet_route_table" {
    route {
        cidr_block                 = "0.0.0.0/0"
        gateway_id                 = aws_nat_gateway.nat_gateway.id
    }
    tags             = {
        "Name" = "private-subnet-route-table"
    }
    vpc_id           = aws_vpc.vpc.id
}

# ルートテーブルをパブリックサブネットに紐付け
# これでパブリックサブネットが外部に公開された状態に
resource "aws_route_table_association" "public_subnet_association" {
    route_table_id = aws_route_table.public_subnet_route_table.id
    subnet_id      = aws_subnet.public_subnet.id
}

# ルートテーブルをプライベートサブネットに紐付け
# これでNAT Gatewayを通して外部に出れる
resource "aws_route_table_association" "private_subnet_association" {
    route_table_id = aws_route_table.private_subnet_route_table.id
    subnet_id      = aws_subnet.private_subnet.id
}
