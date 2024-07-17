# Inspiration: https://saitejamakani.medium.com/automated-migration-of-amazon-ebs-volumes-from-gp2-to-gp3-using-python-and-boto3-65ec51d2ba91
import boto3
import os
import logging
import json

REGION = os.environ.get('REGION', 'us-east-2')
LOG_LEVEL = os.environ.get('LOG_LEVEL', 'INFO')
MODIFY_EBS = os.environ.get('MODIFY_EBS', True)
SNS_TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN')

ec2 = boto3.client('ec2', REGION)
sns = boto3.client('sns', REGION)

def get_ec2_volumes(filter, REGION):
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

            volumes.append({
                "VolumeId": volume['VolumeId'],
                "VolumeType": volume['VolumeType'],
                "AWS-CreateTime": volume['CreateTime'].strftime('%Y-%m-%dT%H:%M:%S.%fZ'),
                "Iops": volume['Iops'],
                "State": volume['State'],
                "Size": volume['Size'],
                "Throughput": throughput_
            })

    message = {
        "Volumes": volumes,
        "Count": len(volumes)
    }

    sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Message=json.dumps(message),
        Subject="EC2 gp2 Volumes List"
    )

    logging.info("EC2 gp2 resources size: " + str(len(volumes)))
    return volumes

def modify_volume_gp3(volume_ids, REGION):
    modify_response = {}
    for volume_id in volume_ids:
        try:
            response = ec2.modify_volume(VolumeId=volume_id, VolumeType='gp3')
            modify_response[volume_id] = response
        except Exception as e:
            logging.error(f"Exception to modify volume: {volume_id} -> {str(e)}")

    if modify_response:
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=json.dumps(modify_response),
            Subject="Modified Volumes"
        )
        logging.info(f"Modified volumes: {modify_response}")

def lambda_handler(event, context):
    try:
        filter = [{'Name': 'volume-type', 'Values': ['gp2']}]
        # get gp2 volumes list
        volumes = get_ec2_volumes(filter, REGION)
        gp2_volume_ids = [volume['VolumeId'] for volume in volumes]
        # Modify gp2 volumes to gp3
        if bool(MODIFY_EBS): modify_volume_gp3(gp2_volume_ids, REGION)
    except Exception as e:
        logging.error("Exception: " + str(e))
        raise e