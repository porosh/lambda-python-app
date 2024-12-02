import json
from src.lambda_function import lambda_handler

def test_lambda_handler():
    event = {"key": "value"}
    context = {}
    response = lambda_handler(event, context)
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert "message" in body