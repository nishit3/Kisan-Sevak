import boto3
import json


tableName = "farm-alert-notifs"
dynamoDB = boto3.resource('dynamodb')
table = dynamoDB.Table(tableName)


def lambda_handler(event, context):
    response = table.scan()
    result = response["Items"]
    
    while 'LastEvaluatedKey' in response:
        response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
        result.extend(response['Items'])

    body = {
        "alerts": result
    }
    return buildResponse(200, body)


def buildResponse(statusCode, body=None):
    response = {
        'statusCode': statusCode,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        }
    }
    if body is not None:
        response['body'] = json.dumps(body)

    return response
