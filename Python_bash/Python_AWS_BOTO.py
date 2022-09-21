import boto3
from tabulate import tabulate
from collections import defaultdict
from smtplib import SMTP
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from pretty_html_table import build_table 
import pandas as pd


"""
A tool for retrieving basic information from the running EC2 instances.
"""

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
#print(dfIssues)



def send_mail(body):
    
    message = MIMEMultipart()
    message['Subject'] = 'List of Impaired Instances'
    message['From'] = 'MAIL_ID'
    message['To'] = 'MAIL_ID'

    body_content = body
    message.attach(MIMEText(body_content, "html"))
    msg_body = message.as_string()

    server = SMTP('smtp.gmail.com', 587)
    server.starttls()
    server.login(message['From'], 'MAILAPITOKEN')
    server.sendmail(message['From'], message['To'], msg_body)
    server.quit()

def send_country_list():
    gdp_data = dfIssues
    output = build_table(gdp_data, 'blue_light')
    send_mail(output)
    return "Mail sent successfully."

print(send_country_list())
