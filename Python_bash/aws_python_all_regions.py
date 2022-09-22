import boto3
from botocore.config import Config

CHECK = "running"


def available_regions(service):
    regions = []
    client = boto3.client(service)
    response = client.describe_regions()

    for item in response["Regions"]:
        regions.append(item["RegionName"])

    return regions


def main():
    print(f"Check for status: {CHECK}")
    regions = available_regions("ec2")

    # Check status of EC2 in each region
    cnt = 0
    for region in regions:

        # Change regions with config
        my_config = Config(region_name=region)
        client = boto3.client("ec2", config=my_config)
        response = client.describe_instances()

        for r in response["Reservations"]:
            status = r["Instances"][0]["State"]["Name"]
            if status == "running":
                instance_id = r["Instances"][0]["InstanceId"]
                instance_type = r["Instances"][0]["InstanceType"]
                az = r["Instances"][0]["Placement"]["AvailabilityZone"]
                print(f"id: {instance_id}, type: {instance_type}, az: {az}")
                cnt += 1

    if cnt == 1:
        print(f"{cnt} instance is {CHECK}!")
    elif cnt > 1:
        print(f"{cnt} instances are {CHECK}!")
    else:
        print(f"No instance is {CHECK}!")


if __name__ == "__main__":
    main()
