#function-handler
function handler () {
    EVENT_DATA=$1
   #PASS_THE_ROLE_ARN
RoleARN=( 'PASS_ARN' 'PASS_ARN')

#to switch role and send ses mail .
OUT2=$(aws sts assume-role --role-arn 'PASS_ARN_MAIN_DEFAULT' --role-session-name aaa )

for  i in "${RoleARN[@]}";do 


    OUT=$(aws sts assume-role --role-arn $i --role-session-name aaa);\
    export AWS_ACCESS_KEY_ID=$(echo $OUT | jq -r '.Credentials''.AccessKeyId');\
    export AWS_SECRET_ACCESS_KEY=$(echo $OUT | jq -r '.Credentials''.SecretAccessKey');\
    export AWS_SESSION_TOKEN=$(echo $OUT | jq -r '.Credentials''.SessionToken');
    

  for region in `aws ec2  describe-regions --output text | cut -f3` ;do
     
     	 echo "USER: $i "
         echo -e "\nListing Instances in region:'$region'..."
        ConfigName=`aws ec2 --region $region describe-instance-status --filters Name=instance-status.status,Values=impaired --query "InstanceStatuses[*].{InstanceId: InstanceId}" --output text` 
        if [ -z "$ConfigName" ];then 
            echo "_____________________________"  
            echo "INSTANCE NOT FOUND cIN $region "
            echo "_____________________________"			
        else  
              aws ec2  --region $region describe-instances --instance-ids $ConfigName \
            --query "Reservations[*].Instances[*].{Instanceid :InstanceId,Name:Tags[?Key=='Name']|[0].Value,PrivateIP:PrivateIpAddress,Az:Placement.AvailabilityZone}" \
            --filters Name=instance-state-name,Values=running \
            --output table
            
         
            Account="CHECKING IN ACCOUNT '$i' IN '$region' :"
            echo -e  "\n ***************************** "  >> /tmp/sample.txt
            
             
             echo -e  "\n '$Account' "  >> /tmp/sample.txt
             
             echo -e  "\n ***************************** "  >> /tmp/sample.txt
            
            
            
            aws ec2 --region $region describe-instances --instance-ids $ConfigName \
            --query "Reservations[].Instances[].{Instanceid :InstanceId,Name:Tags[?Key=='Name']|[0].Value,PrivateIP:PrivateIpAddress,Az:Placement.AvailabilityZone}" \
            --filters Name=instance-state-name,Values=running \
            --output table >> /tmp/sample.txt
          
            # account_no= echo "$i" | cut -d : -f 5
          
            export AWS_ACCESS_KEY_ID=$(echo $OUT2 | jq -r '.Credentials''.AccessKeyId');\
            export AWS_SECRET_ACCESS_KEY=$(echo $OUT2 | jq -r '.Credentials''.SecretAccessKey');\
            export AWS_SESSION_TOKEN=$(echo $OUT2 | jq -r '.Credentials''.SessionToken');
    
       
            
         
        fi
        

    done
    

    
done


sample_data="$(cat /tmp/sample.txt )"
#sending mail via SES
aws ses send-email --from EMAIL_ID --to EMAIL_ID --text "$sample_data " --subject "List of Impaired instances of account"

}



























