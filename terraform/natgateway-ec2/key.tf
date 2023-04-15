resource "aws_key_pair" "key_pair" {
  # ssh-keygen -t rsa -f example -N ''
  # ssh -i ./example ec2-user@35.77.206.159
  key_name   = "example"
  public_key = file("./example.pub")
}
