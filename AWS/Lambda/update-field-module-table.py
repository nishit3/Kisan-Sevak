import json
import boto3
from decimal import Decimal
from datetime import datetime

client = boto3.client('sagemaker-runtime')
dynamoDB = boto3.resource('dynamodb')
fm_Table = dynamoDB.Table("Field-Modules-Data")
notif1 = dynamoDB.Table("farm-alert-notifs")
notif2 = dynamoDB.Table("home-module-notifs")

def lambda_handler(event, context):
    
    fmUID = event['queryStringParameters']['fmUID']
    temp = float(event['queryStringParameters']['Temperature'])
    humid = float(event['queryStringParameters']['Humidity'])
    moist = float(event['queryStringParameters']['Moisture'])
    nitr = float(event['queryStringParameters']['Nitrogen'])
    pot = float(event['queryStringParameters']['Potassium'])
    phs = float(event['queryStringParameters']['Phosphorous'])
    pH = float(event['queryStringParameters']['pH'])
    rain = 12.00                                                     # call api to get info abt rain in mm
    
    
    if rain <=80.00 and moist <= 50.00:
        now = datetime.utcnow()
        currentDateTime = now.strftime("%d/%m/%Y %H:%M:%S")
        notif1.put_item(
            Item={
                    'notifUID': currentDateTime+" Ir",
                    'Type': "Ir",
                    'Msg': "Irrigation is required",
                }
        )
        notif2.put_item(
            Item={
                    'UID': currentDateTime+" Ir",
                    'Type': "Ir",
                }
        )
    
    
    crop_and_soil_type = fm_Table.get_item(
        Key={
        'fmUID': fmUID
        },
        AttributesToGet=[
        'CropType', 'SoilType'
        ],
    )
    
    crop_type = crop_and_soil_type['Item']['CropType']
    soil_type = crop_and_soil_type['Item']['SoilType']
    
    
    body = {
        'Temperature': temp,
        'Humidity': humid,
        'Moisture': moist,
        'Nitrogen': nitr,
        'Potassium': pot,
        'Phosphorous': phs,
        'Crop_Type': crop_type,
        'Soil_Type': soil_type
    }
    
    response = client.invoke_endpoint(
        EndpointName='pytorch-inference-ENDPOINT', 
        ContentType='application/json',
        Body=json.dumps(body)
    )
   
    response_body = response['Body']
    response_str = response_body.read().decode('utf-8')
    best_fertilizer = eval(response_str)
    print(best_fertilizer)
    
    
    body2 = {
        'Nitrogen': nitr,
        'Phosphorous': phs,
        'Potassium': pot,
        'Temperature': temp,
        'Humidity': humid,
        'pH': pH,
        'rainfall': rain
    }
    
    response2 = client.invoke_endpoint(
        EndpointName='pytorch-inference-ENDPOINT', 
        ContentType='application/json',
        Body=json.dumps(body2)
    )
   
    response_body2 = response2['Body']
    response_str2 = response_body2.read().decode('utf-8')
    best_crop = eval(response_str2)
    print(best_crop)
    
    
    fm_Table.update_item(
        Key={'fmUID': fmUID},
        UpdateExpression="set BestFertilizer = :a, RecommendedCrop = :b, Humidity = :c, Moisture = :d, Nitrogen = :e, pH = :f, Phosphorous = :g, Potassium = :h, rain = :i, Temperature = :j",
        ExpressionAttributeValues={
            ":a": str(best_fertilizer), 
            ":b": str(best_crop),
            ":c": Decimal(str(humid)),
            ":d": Decimal(str(moist)),
            ":e": Decimal(str(nitr)),
            ":f": Decimal(str(pH)),
            ":g": Decimal(str(phs)),
            ":h": Decimal(str(pot)),
            ":i": Decimal(str(rain)),
            ":j": Decimal(str(temp))
        },
        ReturnValues="UPDATED_NEW",
    )
   
    return {
        'statusCode': 200,
        'headers': {
            'allow-access-control-origin': '*'
        },
        'body': json.dumps('SUCCESS')
    }
