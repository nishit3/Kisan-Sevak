import json
import boto3

dynamoDB = boto3.resource('dynamodb')
notif1 = dynamoDB.Table("farm-alert-notifs")

def lambda_handler(event, context):
    
    requestBody = json.loads(event['body'])
    notifUID = requestBody["notifUID"]
    notif1.delete_item(
        Key={
            "notifUID": notifUID
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
