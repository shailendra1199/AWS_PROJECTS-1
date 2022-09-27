#function-handler
function handler () {
    EVENT_DATA=$1
RoleARN=( 'arn:aws:iam::737405767796:role/assumeAdmin01' 'arn:aws:iam::149696084264:role/AWS-BASHROLE')
# 'arn:aws:iam::149696084264:role/AWS-BASHROLE'
#to switch role and send ses mail .
OUT2=$(aws sts assume-role --role-arn arn:aws:iam::149696084264:role/AWS-BASHROLE --role-session-name aaa )

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
            
            # * aws_var=`aws ec2 --region $region describe-instances --instance-ids $ConfigName \
            # --query "Reservations[].Instances[].{Instanceid :InstanceId,Name:Tags[?Key=='Name']|[0].Value,PrivateIP:PrivateIpAddress,Az:Placement.AvailabilityZone}" \
            # --filters Name=instance-state-name,Values=running \
            # --output json` >> /tmp/sample.json
            
            Account="CHECKING IN ACCOUNT '$i' IN '$region' :"
            echo -e  "\n ***************************** "  >> /tmp/sample.txt
            
             
             echo -e  "\n '$Account' "  >> /tmp/sample.txt
             
             
             echo -e  "\n ***************************** "  >> /tmp/sample.txt
            
            aws ec2 --region $region describe-instances --instance-ids $ConfigName \
            --query "Reservations[].Instances[].{Instanceid :InstanceId,Name:Tags[?Key=='Name']|[0].Value,PrivateIP:PrivateIpAddress,Az:Placement.AvailabilityZone}" \
            --filters Name=instance-state-name,Values=running \
            --output table >> /tmp/sample.txt
             
            
            
            # echo "line no34"
            # account_no= echo "$i" | cut -d : -f 5
          
            export AWS_ACCESS_KEY_ID=$(echo $OUT2 | jq -r '.Credentials''.AccessKeyId');\
            export AWS_SECRET_ACCESS_KEY=$(echo $OUT2 | jq -r '.Credentials''.SecretAccessKey');\
            export AWS_SESSION_TOKEN=$(echo $OUT2 | jq -r '.Credentials''.SessionToken');
    
            
            #* aws ses send-email --from shailendrasingh.ss205@gmail.com --to shailendrasingh.ss205@gmail.com --text "$aws_var" --subject "List of Impaired instances of account $i"

    
            #  aws ses send-email --source-arn arn:aws:ses:us-east-1:149696084264:identity/shailendrasingh.ss205@gmail.com  --destinations  arn:aws:ses:us-east-1:149696084264:identity/shailendrasingh.ss205@gmail.com   --text "$aws_var" --subject "List of Impaired instances "

            # unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
            
            # aws sts get-caller-identity
        
            
            # aws sts assume-role --role-arn arn:aws:iam::149696084264:role/AWS-BASHROLE --role-session-name ttt
        
            # aws ses send-email --from shailendrasingh.ss205@gmail.com --to shailendrasingh.ss205@gmail.com --text "$aws_var" --subject "List of Impaired instances "

 
 
 
            # echo aws sts get-caller-identity
            
            
            
            # aws ses send-email --source-arn arn:aws:ses:us-east-1:149696084264:identity/shailendrasingh.ss205@gmail.com --to targaryen1199@gmail.com --text "$aws_var" --subject "List of Impaired instances "

            
            
            
            # aws ses send-email --source shailendrasingh.ss205@gmail.com  --return-path arn:aws:ses:us-east-1:149696084264:identity/shailendrasingh.ss205@gmail.com   --to shailendrasingh.ss205@gmail.com --text "$aws_var" --subject "List of Impaired instances "
            
            # aws ses send-email --source-arn arn:aws:ses:us-east-1:149696084264:identity/shailendrasingh.ss205@gmail.com  --destinations  arn:aws:ses:us-east-1:149696084264:identity/shailendrasingh.ss205@gmail.com   --text "$aws_var" --subject "List of Impaired instances "

            # aws ses send-raw-email --from-arn  arn:aws:ses:us-east-1:149696084264:identity/shailendrasingh.ss205@gmail.com --from shailendrasingh.ss205@gmail.com --destinations shailendrasingh.ss205@gmail.com --raw-message Data="$aws_var" 
            
        fi
        

    done
    

    
done

sample_data="$(cat /tmp/sample.txt )"
aws ses send-email --from shailendrasingh.ss205@gmail.com --to shailendrasingh.ss205@gmail.com --text "$sample_data " --subject "List of Impaired instances of account"

}
























# function handler () {
#     EVENT_DATA=$1

# # unset AWS_ACCESS_KEY_ID 
# # unset AWS_SECRET_ACCESS_KEY 
# # unset AWS_SESSION_TOKEN
# # aws sts get-caller-identity

# aws sts get-caller-identity

# OUT=$(aws sts assume-role --role-arn arn:aws:iam::737405767796:role/assumeAdmin01 --role-session-name aaa);\
# export AWS_ACCESS_KEY_ID=$(echo $OUT | jq -r '.Credentials''.AccessKeyId');\
# export AWS_SECRET_ACCESS_KEY=$(echo $OUT | jq -r '.Credentials''.SecretAccessKey');\
# export AWS_SESSION_TOKEN=$(echo $OUT | jq -r '.Credentials''.SessionToken');

# # aws sts assume-role --role-arn  "arn:aws:iam::737405767796:role/assumeAdmin01" --role-session-name "aaa"  
# ConfigName=`aws ec2 --region us-east-1 describe-instance-status --filters Name=instance-status.status,Values=impaired --query "InstanceStatuses[*].{InstanceId: InstanceId}" --output text`

# aws ec2 describe-instances --region us-east-1 --instance-ids $ConfigName \
#             --query "Reservations[].Instances[].{Instanceid :InstanceId,Name:Tags[?Key=='Name']|[0].Value,PrivateIP:PrivateIpAddress,Az:Placement.AvailabilityZone}" \
#             --filters Name=instance-state-name,Values=running \
#             --output table
            
# aws_var=`aws ec2 describe-instances --instance-ids $ConfigName \
#             --query "Reservations[].Instances[].{Instanceid :InstanceId,Name:Tags[?Key=='Name']|[0].Value,PrivateIP:PrivateIpAddress,Az:Placement.AvailabilityZone}" \
#             --filters Name=instance-state-name,Values=running \
#             --output table`




# aws ses send-email --from shailendrasingh.ss205@gmail.com --to shailendrasingh.ss205@gmail.com --text "$aws_var" --subject "List of Impaired instances "


# aws_var=`aws ec2 describe-instances --instance-ids $ConfigName \
#             --query "Reservations[].Instances[].{Instanceid :InstanceId,Name:Tags[?Key=='Name']|[0].Value,PrivateIP:PrivateIpAddress,Az:Placement.AvailabilityZone}" \
#             --filters Name=instance-state-name,Values=running \
#             --output table`


# unset AWS_ACCESS_KEY_ID
# unset AWS_SECRET_ACCESS_KEY
# unset AWS_SESSION_TOKEN


# aws ses send-email --from shailendrasingh.ss205@gmail.com --to shailendrasingh.ss205@gmail.com --text "$aws_var" --subject "List of Impaired instances "


# unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN

# aws sts get-caller-identity














# aws ec2 --region us-east-1 describe-instance-status --filters Name=instance-status.status,Values=impaired --query "InstanceStatuses[*].{InstanceId: InstanceId}" --output text 

#     aws_var=''
#     for region in `aws ec2  describe-regions --output text --query Regions[*].[RegionName]`;do
# #listing all the impaird instances in a region us-east-1
#         echo -e "\nListing Instances in region:'$region'..."
#         ConfigName=`aws ec2   --region $region describe-instance-status --filters Name=instance-status.status,Values=impaired --query "InstanceStatuses[*].{InstanceId: InstanceId}" --output text` 

#         # aws_var="${aws_var} ${notfound}"
     
#          temp=`aws ec2 describe-instances --region $region --instance-ids $ConfigName \
#             --query "Reservations[].Instances[].{Instanceid :InstanceId,Name:Tags[?Key=='Name']|[0].Value,PrivateIP:PrivateIpAddress,Az:Placement.AvailabilityZone}" \
#             --filters Name=instance-state-name,Values=running \
#             --output table`
        
#         aws_var="${aws_var} ${temp}"
            

#     done
    
#         aws ses send-email --from shailendrasingh.ss205@gmail.com  --to shailendrasingh.ss205@gmail.com  --text "$aws_var" --subject "List of Impaired instances "



# function handler () {
#     EVENT_DATA=$1



#     for region in `aws ec2 describe-regions --region us-east-1 --output text --query Regions[*].[RegionName]`;do
     
#         echo -e "\nListing Instances in region:'$region'..."
#         ConfigName=`aws ec2 --region $region describe-instance-status --filters Name=instance-status.status,Values=impaired --query "InstanceStatuses[*].{InstanceId: InstanceId}" --output text` 
            
            
#         aws_var=`aws ec2 describe-instances --instance-ids $ConfigName \
#             --query "Reservations[*].Instances[*].{Instanceid :InstanceId,Name:Tags[?Key=='Name']|[0].Value,PrivateIP:PrivateIpAddress,Az:Placement.AvailabilityZone}" \
#             --filters Name=instance-state-name,Values=running \
#             --output table`
            
#             aws ses send-email --from shailendrasingh.ss205@gmail.com --to shailendrasingh.ss205@gmail.com --text "$aws_var" --subject "List of Impaired instances "

        
        
        
#     done

# }



