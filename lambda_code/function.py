import boto3
import json
import os
from function2 import helper_func
os.environ.get("email_address")

def lambda_handler(event, context):
    print(event)
    print(context)
    s3_bucket = event["Records"][0]["s3"]["bucket"]["name"]
    s3_key = event["Records"][0]["s3"]["object"]["key"]
    email=os.environ.get("email_address")
    ses_client = boto3.client("ses")
    send_arg = {
        "Source": email,
        "Destination": {
            "ToAddresses": [
                email
            ]  # Provide the recipient email address as a list
        },
        "Message": {
            "Subject": {"Data": "New S3 Object Created"},
            "Body": {
                "Text": {
                    "Data": f"A new object was created in S3 bucket- {s3_bucket} .\nObject key: {s3_key}"
                }
            },
        },
    }
    response = ses_client.send_email(**send_arg)
    return response
