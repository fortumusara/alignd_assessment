import boto3
import pandas as pd
import os
import logging

s3 = boto3.client('s3')
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    try:
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key']

        # Download parquet
        download_path = f"/tmp/{os.path.basename(key)}"
        s3.download_file(bucket, key, download_path)

        # Convert parquet → CSV
        df = pd.read_parquet(download_path)
        csv_path = download_path.replace(".parquet", ".csv")
        df.to_csv(csv_path, index=False)

        # Upload to processed bucket
        processed_bucket = "<initials>-processed-bucket-analytics"
        s3.upload_file(csv_path, processed_bucket, os.path.basename(csv_path))

        logger.info(f"Successfully processed {key}")

    except Exception as e:
        # Move to /error/ prefix
        error_key = f"error/{os.path.basename(key)}"
        s3.copy_object(
            Bucket=bucket,
            CopySource={'Bucket': bucket, 'Key': key},
            Key=error_key
        )
        s3.delete_object(Bucket=bucket, Key=key)
        logger.error(f"Error processing {key}: {str(e)}")
