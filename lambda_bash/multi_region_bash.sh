
function handler() {
    EVENT_DATA=$1

# unset AWS_ACCESS_KEY_ID 
# unset AWS_SECRET_ACCESS_KEY 
# unset AWS_SESSION_TOKEN
# aws sts get-caller-identity
            
OUT=$(aws sts assume-role --role-arn #PASS_ARN --role-session-name aaa);\
export AWS_ACCESS_KEY_ID=$(echo $OUT | jq -r '.Credentials''.AccessKeyId');\
export AWS_SECRET_ACCESS_KEY=$(echo $OUT | jq -r '.Credentials''.SecretAccessKey');\
export AWS_SESSION_TOKEN=$(echo $OUT | jq -r '.Credentials''.SessionToken');

# aws sts assume-role --role-arn  "arn:aws:iam::737405767796:role/assumeAdmin01" --role-session-name "aaa"  
ConfigName=`aws ec2 --region us-east-1 describe-instance-status --filters Name=instance-status.status,Values=impaired --query "InstanceStatuses[*].{InstanceId: InstanceId}" --output text`

aws ec2 describe-instances --region us-east-1 --instance-ids $ConfigName \
            --query "Reservations[].Instances[].{Instanceid :InstanceId,Name:Tags[?Key=='Name']|[0].Value,PrivateIP:PrivateIpAddress,Az:Placement.AvailabilityZone}" \
            --filters Name=instance-state-name,Values=running \
            --output table
            
aws_var=`aws ec2 describe-instances --instance-ids $ConfigName \
            --query "Reservations[].Instances[].{Instanceid :InstanceId,Name:Tags[?Key=='Name']|[0].Value,PrivateIP:PrivateIpAddress,Az:Placement.AvailabilityZone}" \
            --filters Name=instance-state-name,Values=running \
            --output table`




aws ses send-email --from [MAIL_ID] --to [MAIL_ID --text "$aws_var" --subject "List of Impaired instances "

}
