
profile=( default Tom )
user=$1

okta-aws $1 sts get-caller-identity

for elements in "${profile[@]}"; do


    for region in `aws ec2  --profile $elements describe-regions --output text | cut -f4` ;do
     
     
         echo -e "\nListing Instances in region:'$region'..."
        ConfigName=`aws ec2 --profile $elements --region $region describe-instance-status --filters Name=instance-status.status,Values=impaired --query "InstanceStatuses[*].{InstanceId: InstanceId}" --output text` 
        if [ -z "$ConfigName" ];then 
            echo "_____________________________"  
            echo "INSTANCE NOT FOUND IN $region "
            echo "_____________________________"
        else     
              aws ec2 --profile $elements --region $region describe-instances --instance-ids $ConfigName \
            --query "Reservations[*].Instances[*].{Instanceid :InstanceId,Name:Tags[?Key=='Name']|[0].Value,PrivateIP:PrivateIpAddress,Az:Placement.AvailabilityZone}" \
            --filters Name=instance-state-name,Values=running \
            --output table
        fi
    done 
    echo ""
    echo ""
    echo "Checking in Diffrent Profile : "${profile[1]}" "
    # echo "Checking in Diffrent Profile ${profile[@]}}" 
    
done

 
