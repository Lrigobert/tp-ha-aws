def lambda_handler(event, context):
    print("Fichier uploade d?tect? !")
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        print(f"Bucket: {bucket}, Key: {key}")
    return {
        'statusCode': 200,
        'body': 'Success'
    }
