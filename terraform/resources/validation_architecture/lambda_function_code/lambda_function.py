import os
import json
import urllib.request

def lambda_handler(event, context):
    alb_dns = os.environ.get("ALB_DNS")

    if not alb_dns:
        return {
            "statusCode": 500,
            "body": "ALB DNS not configured"
        }

    url = f"http://{alb_dns}"

    try:
        with urllib.request.urlopen(url, timeout=5) as response:
            body = response.read().decode("utf-8")

        return {
            "statusCode": 200,
            "body": json.dumps({
                "alb_response": body
            })
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": str(e)
        }
