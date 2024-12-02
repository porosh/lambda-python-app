import json
import requests
from utils import helper_function
from config import CONFIG

def lambda_handler(event, context):
    """
    Entry point for AWS Lambda.
    """

    try:
        # Make a GET request to google.com
        response = requests.get("https://www.google.com")
        status_code = response.status_code
        body = response.text[:500]  # Limit response body for logging
        
        return {
            "statusCode": status_code,
            "body": f"Google responded with status {status_code}. Here's a snippet: {body}"
        }
    except requests.exceptions.RequestException as e:
        return {
            "statusCode": 500,
            "body": f"Error occurred while making request to Google: {str(e)}"
        }


    try:
        message = helper_function("Lambda is running!")
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": message,
                "configValue": CONFIG.get("example_key", "default_value")
            }),
        }
    except Exception as e:
        print(f"KeyError: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)}),
        }
