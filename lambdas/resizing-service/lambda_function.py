import json
import boto3
import os
import logging

REGION = os.environ.get('REGION', 'us-east-2')
LOG_LEVEL = os.environ.get('LOG_LEVEL', 'INFO')

logging.basicConfig(level=LOG_LEVEL)
ecs_client = boto3.client('ecs', REGION)

def lambda_handler(event, context):
    cluster_name = event['cluster_name']
    service_name = event['service_name']
    desired_count = event['desired_count']
    
    try:
        # Update the service with the new desired count
        response = ecs_client.update_service(
            cluster=cluster_name,
            service=service_name,
            desiredCount=desired_count
        )
        
        logging.info(f"Response: {response}")

        return {
            'statusCode': 200,
            'body': json.dumps(f"Successfully updated {service_name} to {desired_count} tasks.")
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error updating service: {str(e)}")
        }
