import json
import boto3

dynamoDB = boto3.resource('dynamodb')
notif2 = dynamoDB.Table("home-module-notifs")

def lambda_handler(event, context):
    
    UID = event['queryStringParameters']['UID']
    notif2.delete_item(
        Key={
            "UID": UID
        },
        ReturnValues='ALL_OLD'
    )
    
    return {
        'statusCode': 200,
        'headers': {
            'allow-access-control-origin': '*'
        },
        'body': json.dumps('DELETED')
    }
