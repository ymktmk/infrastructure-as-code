# ECSとRDSを検証したい時は以下のコメントアウトを外して terraform init
# module "expensive_module" {
#   providers = {
#     aws          = aws
#     aws.virginia = aws.virginia
#   }
#   source              = "../expensive_module"
#   aws_account_id      = "009554248005"
#   encer_domain        = "stg.encer.jp"
#   env_name            = "stg"
#   vpc_id              = module.common_module.vpc_id
#   public_subnet_1a_id = module.common_module.public_subnet_1a_id
#   route53_zone_id     = module.common_module.route53_zone_id
# }

module "common_module" {
  providers = {
    aws          = aws
    aws.virginia = aws.virginia
  }
  source         = "../common_module"
  aws_account_id = "009554248005"
  encer_domain   = "stg.encer.jp"
  env_name       = "stg"
}
