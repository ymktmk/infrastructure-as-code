#!/bin/sh
stack=$1
create_changeset=`aws cloudformation create-change-set 
  --stack-name $stack \
  --template-body=./cloudformation/vpc.yaml`
changeset_id=`echo ${create_changeset} | jq -r '.Id'`
changeset_json=$(aws cloudformation describe-change-set --change-set-name $changeset_id)
stack_name=$(echo "$changeset_json" | jq -r .StackName)
changes=$(echo "$changeset_json" | jq -r .Changes)
changes_length=$(echo "$changes" | jq length)
echo "<details><summary><code>$stack_name ($changes_length changes)</code></summary>" # クリックで展開できるやつ
echo
if [ $changes_length -gt 0 ]; then
echo '|Action|論理ID|物理ID|リソースタイプ|置換|' # 少しでも横幅を減らすためにActionだけ英語
echo '|---|---|---|---|---|'
for i in $( seq 0 $(($changes_length - 1)) ); do
  row=$(echo "$changes" | jq -r .[$i].ResourceChange)
  col_1=$(echo "$row" | jq -r .Action)
  col_2=$(echo "$row" | jq -r .LogicalResourceId)
  col_3=$(echo "$row" | jq -r .PhysicalResourceId | sed -e 's/null/-/') # nullの場合'-'を表示
  col_4=$(echo "$row" | jq -r .ResourceType | sed -e 's/AWS:://') # リソースタイプの'AWS::'は省略
  col_5=$(echo "$row" | jq -r .Replacement | sed -e 's/null/-/' | sed -e 's/True/\*\*True\*\*/') # nullの場合'-'を表示。Trueなら太字にする
  echo "|$col_1|$col_2|$col_3|$col_4|$col_5|"
done
fi
echo '<ul><li><details><summary>view json</summary>' # インデントを付ける目的でリストにしている
echo
echo '```json'
echo "$changeset_json"
echo '```'
echo '</details></li></ul></details>'
