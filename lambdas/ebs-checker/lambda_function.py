# Inspiration: https://saitejamakani.medium.com/automated-migration-of-amazon-ebs-volumes-from-gp2-to-gp3-using-python-and-boto3-65ec51d2ba91
import csv
import boto3
import os
import logging

REGION = os.environ.get('REGION', 'us-east-2')
LOG_LEVEL = os.environ.get('LOG_LEVEL', 'INFO')
MODIFY_EBS = os.environ.get('MODIFY_EBS', True)

def get_ec2_volumes(file_name, filter, REGION):
    ec2 = boto3.client('ec2', REGION)
    paginator = ec2.get_paginator('describe_volumes')
    paginationConfig_ = {'MaxItems': 500, 'PageSize': 500}
    response_iterator = paginator.paginate(
        Filters=filter, PaginationConfig=paginationConfig_)
    volumes = []
    for page in response_iterator:
        volumes_result = page['Volumes']
        for volume in volumes_result:
            if 'Throughput' in volume:
                throughput_ = volume['Throughput']
            else:
                throughput_ = None

            volumes.append([volume['VolumeId'],
                            volume['VolumeType'],
                            volume['CreateTime'],
                            volume['Iops'],
                            volume['State'],
                            volume['Size'],
                            throughput_])

    with open(file_name, "w", newline="") as file:
        writer = csv.writer(file)
        # Write Header
        writer.writerow(
            [
                "VolumeId",
                "VolumeType",
                "AWS-CreateTime",
                "Iops",
                "State",
                "Size",
                "Throughput"
            ]
        )
        # Write volumes list
        writer.writerows(volumes)
    logging.info("EC2 gp2 resources size: " + str(len(volumes)))
    return volumes

def modify_volume_gp3(volume_ids, REGION):
    ec2 = boto3.client('ec2', REGION)
    modify_response = {}
    for volume_id in volume_ids:
        try:
            response = ec2.modify_volume(VolumeId=volume_id, VolumeType='gp3')
            response = []
            modify_response[volume_id] = response
        except Exception as e:
            logging.error(f"Exception to modify volume: {volume_id} -> {str(e)}")

    if modify_response != {}:
        logging.info(f"Modified volumes: {modify_response}" )
        with open("./modified_volumes.json", "w", newline="") as mod_file:
            writer = csv.writer(mod_file)
            writer.writerows(modify_response)
    return

def lambda_handler(event, context):
    try:
        filter = [{'Name': 'volume-type', 'Values': ['gp2']}]
        # File to save list of gp2 volumes
        file_name = "./gp2_volumes_list.csv"
        # get gp2 columes list
        volumes = get_ec2_volumes(file_name, filter, REGION)
        gp2_volume_ids = []
        for volumn in volumes:
            gp2_volume_ids.append(volumn[0])
        # Modify gp2 volumes to gp3
        if bool(MODIFY_EBS): modify_volume_gp3(gp2_volume_ids, REGION)
    except Exception as e:
        logging.error("Exception: " + str(e))
        raise e
