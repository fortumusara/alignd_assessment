#!/bin/bash

initials="fm"
region="af-south-1"
account_id="<your-account-id>"
role_name="<your-role-name>"

# Create buckets
aws s3 mb s3://$initials-source-bucket-analytics --region $region
aws s3 mb s3://$initials-processed-bucket-analytics --region $region

# Package Lambda code
cd etl_lambda
pip install -r requirements.txt -t .
zip -r ../etl_lambda.zip .
cd ..

# Create Lambda function
aws lambda create-function \
  --function-name $initials-etl-function \
  --runtime python3.9 \
  --role arn:aws:iam::$account_id:role/$role_name \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://etl_lambda.zip \
  --region $region
