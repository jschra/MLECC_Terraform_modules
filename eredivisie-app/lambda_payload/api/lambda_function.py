import json
import logging
import boto3
import pandas as pd

logger = logging.getLogger()
logger.setLevel(logging.INFO)

bucket = "terraform-api-data"
file_name = "eredivisie_results.csv"


def lambda_handler(event, context):
    # Log incoming event
    logger.info(event)

    s3 = boto3.client('s3')

    obj = s3.get_object(Bucket=bucket, Key=file_name)

    data = obj['Body']

    df = pd.read_csv(data, sep=';')

    # Filter on season
    try:
        season = event['season']
        df = df[df['Seizoen'] == season]
        print(f'filtered on season {season}')
        logger.info(f'filtered on season {season}')
    except:
        print('no filtering on season')
        logger.info('no filtering on season')

    # Filter on club
    try:
        club = event['club']
        df = df[(df['Thuisclub'] == club) | (df['Uitclub'] == club)]
        print(f'filtered on club {club}')
        logger.info(f'filtered on season {season}')
    except:
        print('no filtering on club')
        logger.info('no filtering on club')

    print(df.head())
    json = df.to_json(orient="records")

    logger.info('returned eredivisie data')

    return {
        'statusCode': 200,
        'body': json
    }
