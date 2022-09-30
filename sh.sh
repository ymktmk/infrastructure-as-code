stack_name="test"
changeset_name=${stack_name}-$(date +%Y%m%d%H%M%S)

create_changeset=`aws cloudformation create-change-set \
                  --stack-name $stack_name \
                  --change-set-name $changeset_name \
                  --template-body file://$PWD/cloudformation/vpc.yaml`

changeset_id=$(echo ${create_changeset} | jq -r .Id)
echo $changeset_id
changeset_json=$(aws cloudformation describe-change-set --change-set-name $changeset_id)
echo $changeset_json
changes=$(echo "$changeset_json" | jq -r .Changes)
changes_length=$(echo "$changes" | jq length)
