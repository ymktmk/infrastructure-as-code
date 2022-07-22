# パブリックサブネットの踏み台EC2
resource "aws_instance" "ec2_instance_1" {
    ami = data.aws_ami.latest_ami.image_id
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public_subnet.id
    vpc_security_group_ids = [aws_security_group.security_group.id]
    key_name               = aws_key_pair.key_pair.id
    tags = {
        Name = "ec2_instance_1"
    }
}

# プライベートサブネットのEC2
resource "aws_instance" "ec2_instance_2" {
    ami = data.aws_ami.latest_ami.image_id
    instance_type = "t2.micro"
    subnet_id = aws_subnet.private_subnet.id
    vpc_security_group_ids = [aws_security_group.security_group.id]
    key_name               = aws_key_pair.key_pair.id
    tags = {
        Name = "ec2_instance_2"
    }
}
