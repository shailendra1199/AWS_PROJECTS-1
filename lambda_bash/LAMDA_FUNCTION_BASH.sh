function handler () {
    EVENT_DATA=$1



    for region in `aws ec2 describe-regions --region us-east-1 --output text --query Regions[*].[RegionName]`;do
     
         echo -e "\nListing Instances in region:'$region'..."
        ConfigName=`aws ec2 --region $region describe-instance-status --filters Name=instance-status.status,Values=impaired --query "InstanceStatuses[*].{InstanceId: InstanceId}" --output text` 
        if [ -z "$ConfigName" ];then 
            echo "_____________________________"  
            echo "INSTANCE NOT FOUND IN $region "
            echo "_____________________________"			
        else     
            aws_var=`aws ec2 describe-instances --instance-ids $ConfigName \
            --query "Reservations[*].Instances[*].{Instanceid :InstanceId,Name:Tags[?Key=='Name']|[0].Value,PrivateIP:PrivateIpAddress,Az:Placement.AvailabilityZone}" \
            --filters Name=instance-state-name,Values=running \
            --output table`
            
            aws ses send-email --from mail_id --to mail_id --text "$aws_var" --subject "List of Impaired instances "

        fi
        
        
    done

}
