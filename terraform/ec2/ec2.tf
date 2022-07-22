resource "aws_instance" "ec2_instance" {
    ami           = data.aws_ami.latest_ami.image_id
    instance_type = "t2.micro"
    # パブリックサブネットに配置
    subnet_id              = aws_subnet.public_subnet.id
    vpc_security_group_ids = [aws_security_group.security_group.id]
    key_name               = aws_key_pair.key_pair.id
    tags = {
        Name = "ec2_instance"
    }
}
