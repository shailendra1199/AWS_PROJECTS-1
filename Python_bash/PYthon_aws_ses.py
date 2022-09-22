"""
PYTHON PROGRAM TO FILTER OUT IMPAIRED ISTANCES FROM THE REGION , AND SEND A SES{AWS MAIL SERVICE } NOTIFICATION TO USER
"""


import boto3
from botocore.exceptions import ClientError
from tabulate import tabulate
from collections import defaultdict
from smtplib import SMTP
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.application import MIMEApplication
from pretty_html_table import build_table 
import pandas as pd


"""
A tool for retrieving basic information from the running EC2 instances.
"""
def send_mail(body):

    # Setup the basics here
    SENDER = "MailID"
    RECIPIENT = "MailID"
    SUBJECT = "List of Imapired Instances"

    # The email body for recipients with non-HTML email clients.
    BODY_TEXT = "Please find the List of Impaired Instances "

    # The character encoding for the email.
    CHARSET = "utf-8"

    # Create a new SES resource and specify a region.
    client = boto3.client('ses')

    # Create an instance of multipart/mixed parent container.
    msg = MIMEMultipart('mixed')

    # Add subject, from and to lines.
    msg['Subject'] = SUBJECT 
    msg['From'] = SENDER 
    msg['To'] = RECIPIENT

    # The email body for recipients with non-HTML email clients.
    BODY_TEXT = "Please find the List of Impaired Instances "

    # The character encoding for the email.
    CHARSET = "utf-8"

    textpart = MIMEText(BODY_TEXT.encode(CHARSET), 'plain', CHARSET)
    msg_body = MIMEMultipart('alternative')
    msg_body.attach(textpart)



    # Create a multipart/alternative child container.
    
    body_content = body

    # Encode the text and HTML content and set the character encoding. This step is
    # necessary if you're sending a message with characters outside the ASCII range.
    msg.attach(MIMEText(body_content,'html'))
    # msg_body = msg.as_string

    msg.attach(msg_body)
  
    try:
        #Provide the contents of the email.
        response = client.send_raw_email(
        Source=SENDER,
        Destinations=[
            RECIPIENT
        ],
        RawMessage={
            'Data':msg.as_string()
        },
        # ConfigurationSetName=CONFIGURATION_SET
    )
        # Display an error if something goes wrong.	
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        print("Email sent! Message ID:"),
        print(response['MessageId'])
    

def send_country_list():
    gdp_data = dfIssues
    output = build_table(gdp_data, 'blue_light')
    send_mail(output)
    return "Mail sent successfully."



def get_instance_name(fid):
    # When given an instance ID as str e.g. 'i-1234567', return the instance 'Name' from the name tag.
    ec2 = boto3.resource('ec2')
    ec2instance = ec2.Instance(fid)
    instancename = ''
    for tags in ec2instance.tags:
        if tags["Key"] == 'Name':
            instancename = tags["Value"]
    return instancename
# Connect to EC2
ec2 = boto3.resource('ec2')


#boto3 aws client
client = boto3.client('ec2')

#printing out all instances with statuc check

#EC2 instances status 
status = client.describe_instance_status(IncludeAllInstances = True)
# print(status)
failed_instances = []
for i in status["InstanceStatuses"]:    
        in_status = i['InstanceStatus']['Details'][0]['Status']
        sys_status = i['SystemStatus']['Details'][0]['Status']
        
        #print(in_status)
        if ((in_status != 'passed') or (sys_status != 'passed')):
             failed_instances.append(i["InstanceId"])
             
#filtring out the impaired instances 


client = boto3.client('ec2')
Myec2=client.describe_instances()

arr = []
for pythonins in Myec2['Reservations']:
      for printout in pythonins['Instances']:
        if printout['InstanceId'] in failed_instances:
            inarr = []
            r = get_instance_name(printout['InstanceId'])
            a = printout['InstanceId']
            b=printout['InstanceType']
            c=printout['PrivateIpAddress']
            d=printout['Placement']
            e = list(d.values())[0]
            inarr.append(r)
            inarr.append(a)
            inarr.append(b)
            inarr.append(c)
            inarr.append(e)

            arr.append(inarr)


dfIssues = pd.DataFrame(arr, columns=["Name","InstanceId","Type","Private IP","Availability Zone"])

# Reframing the columns to get proper
# sequence in output.

columnTiles = ["Name","InstanceId","Type","Private IP","Availability Zone"]
dfIssues = dfIssues.reindex(columns=columnTiles)
# print(dfIssues)

print(send_country_list())

