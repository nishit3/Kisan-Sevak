import json
import boto3

dynamoDB = boto3.resource('dynamodb')
table = dynamoDB.Table("Field-Modules-Data")

def lambda_handler(event, context):
    
    fmUID = event['queryStringParameters']['fmUID']
    reqBody = json.loads(event["body"])
    
    table.update_item(
        Key={'fmUID': fmUID},
        UpdateExpression="set SoilType = :a, CropType = :b",
        ExpressionAttributeValues={
            ":a": reqBody["SoilType"], 
            ":b": reqBody["CropType"]
        },
        ReturnValues="UPDATED_NEW",
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps('UPDATED')
    }
