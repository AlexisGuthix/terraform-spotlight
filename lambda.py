# import the JSON utility package
import json
# import the Python math library
import math
import time

# import the AWS SDK (for Python the package name is boto3)
import boto3

# import two packages to help us with dates and date formatting
from time import gmtime, strftime




# create a DynamoDB object using the AWS SDK
dynamodb = boto3.resource('dynamodb')
# use the DynamoDB object to select our table
table = dynamodb.Table('SpeedlightDatabaseTerra')
# store the current time in a human readable format in a variable
now = strftime("%a, %d %b %Y %H:%M:%S +0000", gmtime())

def lambda_handler(event, context):
    # Extraire la valeur des kilomètres à partir de l'événement
    kilometers = int(event['kilometers'])
    
    timestamp = int(time.time())
    
    response = table.put_item(
        Item={
            'id': str(timestamp),
            'LatestGreetingTime':now,
            'kilometre': int(kilometers)
            })
    
    # Vitesse de la lumière en m/s
    speed_of_light = 299792458
    
    # Conversion des kilomètres en mètres
    meters = kilometers * 1000
    
    # Conversion des mètres en vitesse de la lumière par seconde
    speed_in_light_seconds = meters / speed_of_light
    
    # Calculer le temps nécessaire pour parcourir la distance à 550,000 km/h
    speed_km_per_hour_692000 = 692000
    time_hours_692000 = kilometers / speed_km_per_hour_692000

    # Calculer le temps nécessaire pour parcourir la distance à 300 km/h
    speed_km_per_hour_300 = 300
    time_hours_300 = kilometers / speed_km_per_hour_300
    
    # Calculer le temps nécessaire pour parcourir la distance à 550,000 km/h
    speed_km_per_hour_28000 = 28000
    time_hours_28000 = kilometers / speed_km_per_hour_28000

    # Convertir le temps en jours pour le calcul à 300 km/h
    time_days_300 = time_hours_300 / 24  # Une journée a 24 heures

    # Arrondir les valeurs à trois chiffres après la virgule
    speed_in_light_seconds = round(speed_in_light_seconds, 3)
    time_hours_692000 = round(time_hours_692000, 3)
    time_days_300 = round(time_days_300, 3)
    time_hours_28000 = round(time_hours_28000, 3)

    # Créer une réponse JSON
    response = {
        "Speed of light in seconds": speed_in_light_seconds,
        "Parker Solar at 692,000km/h in hours": time_hours_692000,
        "International Space Station at 28,000km/h in hours": time_hours_28000,
        "Speed of a train at 300km/h in days": time_days_300,

    }

    return {
        "statusCode": 200,
        "body": json.dumps(response)
    }