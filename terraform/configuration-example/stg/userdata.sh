#!/bin/bash

# Install 
yum -y update
yum -y install epel-release
yum -y install jq
yum -y install unzip

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# ECS
echo ECS_CLUSTER=encer-server-stg-cluster >> /etc/ecs/ecs.config

# Route53
HOSTED_ZONE_ID="Z048940128FP257ZTYFTC"
DOMAIN_NAME="stg.encer.jp"
SUB_NAME="api"

# Get EC2 Metadata
INSTANCE_ID=`curl http://169.254.169.254/latest/meta-data/instance-id`

# Create ElasticIP
ELASTIC_IP_JSON=`aws ec2 allocate-address --region ap-northeast-1`
ALLOCATION_Id=`echo ${ELASTIC_IP_JSON} | jq -r '.AllocationId'`
PUBLIC_IP=`echo ${ELASTIC_IP_JSON} | jq -r '.PublicIp'`

# Associate ElasticIP
aws ec2 associate-address \
      --allocation-id ${ALLOCATION_Id} \
      --instance-id ${INSTANCE_ID} \
      --region ap-northeast-1

# JSON *リソースパスを/health変更する
HEALTH_CHECK_JSON='{
      "Type": "HTTP",
      "IPAddress": "'${PUBLIC_IP}'",
      "Port": 80,
      "ResourcePath": "/",
      "RequestInterval": 10,
      "FailureThreshold": 1,
      "Regions": ["ap-northeast-1","ap-southeast-1","ap-southeast-2"]
}'

# Generate Unique String
DATE=`date '+%Y-%m-%d-%H:%M:%S'`

# Create Health Check
HTTP_HEALTH_CHECK=`aws route53 create-health-check \
                  --caller-reference ${DATE} \
                  --health-check-config "${HEALTH_CHECK_JSON}" \
                  --region ap-northeast-1`

HEALTH_CHECK_ID=`echo ${HTTP_HEALTH_CHECK} | jq -r '.HealthCheck.Id'`

BATCH_JSON='{
  "Changes": [
    { "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "'${SUB_NAME}'.'${DOMAIN_NAME}'",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [
          { "Value": "'${PUBLIC_IP}'" }
        ],
        "SetIdentifier": "'${PUBLIC_IP}'",
        "Weight": 50,
        "HealthCheckId": "'${HEALTH_CHECK_ID}'"
      }
    }
  ]
}'

# Create A Record
aws route53 change-resource-record-sets \
      --hosted-zone-id ${HOSTED_ZONE_ID} \
      --change-batch "${BATCH_JSON}" \
      --region ap-northeast-1
