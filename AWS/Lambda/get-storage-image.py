import boto3
import base64

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    
    image_name = event['queryStringParameters']['fmUID']+'.jpeg'
    bucket_name = 'sap-marathon-storage-imgs'
    try:
        response = s3_client.get_object(Bucket=bucket_name, Key=image_name)
        file_content = base64.b64encode(response['Body'].read())
        return {
            'statusCode': 200,
            'headers': {
                'allow-access-control-origin': '*'
            },
            'body': file_content,
            'isBase64Encoded': True,
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'allow-access-control-origin': '*'
            },
            'body': str(e)
        }
