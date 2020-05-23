import json

def default_response(code, body, override={}):
    res = {
        "isBase64Encoded": False,
        "statusCode": code,
        "headers": {
            "Content-Type": "text/html; charset=utf-8",
            "Access-Control-Allow-Origin": "*"
        },
        "body": f"{body}"
    }
    return {**res, **override}

def json_response(code, body=[{}], override={}):
    res = {
        "isBase64Encoded": False,
        "statusCode": code,
        "headers": {
            "Content-Type": "application/json; charset=utf-8"
        },
        "body": body
    }
    return {**res, **override}

def error_response(error, override={}):
    return json_response(code=error.code, body=[{"reason": error.reason, "message": error.message}])

