import json
import boto3
from decimal import Decimal
from datetime import datetime

dynamoDB = boto3.resource('dynamodb')
table = dynamoDB.Table("Storage-Modules-Data")
notif1 = dynamoDB.Table("farm-alert-notifs")
notif2 = dynamoDB.Table("home-module-notifs")


def lambda_handler(event, context):
    
    fmUID = event['queryStringParameters']['fmUID']
    temp = float(event['queryStringParameters']['Temperature'])
    humid = float(event['queryStringParameters']['Humidity'])
    co2 = float(event['queryStringParameters']['CO2'])
    flame = float(event['queryStringParameters']['isFlameDetected'])
    
    
    if flame==1.00:
        now = datetime.utcnow()
        currentDateTime = now.strftime("%d/%m/%Y %H:%M:%S")
        notif1.put_item(
            Item={
                    'notifUID': currentDateTime+" FL",
                    'Type': "FL",
                    'Msg': "Flame detected, Chances of fire are high",
                }
        )
        notif2.put_item(
            Item={
                    'UID': currentDateTime+" FL",
                    'Type': "FL",
                }
        )
        
    if co2 > 600.00:
        now = datetime.utcnow()
        currentDateTime = now.strftime("%d/%m/%Y %H:%M:%S")
        notif1.put_item(
            Item={
                    'notifUID': currentDateTime+" CO2",
                    'Type': "CO2",
                    'Msg': "CO2 is very high, food grains can get spoiled.",
                }
        )
        notif2.put_item(
            Item={
                    'UID': currentDateTime+" CO2",
                    'Type': "CO2",
                }
        )
    
    table.update_item(
        Key={'fmUID': fmUID},
        UpdateExpression="set Temperature = :a, Humidity = :b, CO2 = :c, isFlameDetected = :d",
        ExpressionAttributeValues={
            ":a": Decimal(str(temp)), 
            ":b": Decimal(str(humid)),
            ":c": Decimal(str(co2)),
            ":d": Decimal(str(flame)),
        },
        ReturnValues="UPDATED_NEW",
    )
    
    return {
        'statusCode': 200,
        'headers': {
            'allow-access-control-origin': '*'
        },
        'body': json.dumps('SUCCESS!')
    }
