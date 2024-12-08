# CRUD HTTP API with AWS Lambda and DynamoDB

**Create a CRUD (Create, Read, Update, Delete) HTTP API using AWS Lambda for serverless functions and DynamoDB as the NoSQL database.**

## Steps
### 1. Set Up AWS Lambda
- Sign in to the Lambda console at https://console.aws.amazon.com/lambda.
- Choose Create function.
- For Function name, enter http-crud-function.
- For Runtime, choose the latest supported Python runtime.
- Under Permissions choose Change default execution role.
- Select Create a new role from AWS policy templates.
- For Role name, enter http-crud-role.
- For Policy templates, choose Simple microservice permissions. This policy grants the Lambda function permission to interact with DynamoDB.
- Choose Create function.
- Open the Lambda function in the console's code editor, and replace its contents with the following code. Choose Deploy to update your function.

```python
import json
import boto3
from decimal import Decimal

client = boto3.client('dynamodb')
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table('http-crud-tutorial-items')
tableName = 'http-crud-tutorial-items'


def lambda_handler(event, context):
    print(event)
    body = {}
    statusCode = 200
    headers = {
        "Content-Type": "application/json"
    }

    try:
        if event['routeKey'] == "DELETE /items/{id}":
            table.delete_item(
                Key={'id': event['pathParameters']['id']})
            body = 'Deleted item ' + event['pathParameters']['id']
        elif event['routeKey'] == "GET /items/{id}":
            body = table.get_item(
                Key={'id': event['pathParameters']['id']})
            body = body["Item"]
            responseBody = [
                {'price': float(body['price']), 'id': body['id'], 'name': body['name']}]
            body = responseBody
        elif event['routeKey'] == "GET /items":
            body = table.scan()
            body = body["Items"]
            print("ITEMS----")
            print(body)
            responseBody = []
            for items in body:
                responseItems = [
                    {'price': float(items['price']), 'id': items['id'], 'name': items['name']}]
                responseBody.append(responseItems)
            body = responseBody
        elif event['routeKey'] == "PUT /items":
            requestJSON = json.loads(event['body'])
            table.put_item(
                Item={
                    'id': requestJSON['id'],
                    'price': Decimal(str(requestJSON['price'])),
                    'name': requestJSON['name']
                })
            body = 'Put item ' + requestJSON['id']
    except KeyError:
        statusCode = 400
        body = 'Unsupported route: ' + event['routeKey']
    body = json.dumps(body)
    res = {
        "statusCode": statusCode,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": body
    }
    return res
```

### 2. Create a DynamoDB Table
- Open the DynamoDB console at https://console.aws.amazon.com/dynamodb/.
- Choose Create table.
- For Table name, enter http-crud-items.
- For Partition key, enter id.
- Choose Create table.

### 3. Set Up API Gateway
- Sign in to the API Gateway console at https://console.aws.amazon.com/apigateway.
- Choose Create API, and then for HTTP API, choose Build.
- For API name, enter http-crud-api.
- Choose Next.
- For Configure routes, choose Next to skip route creation. You create routes later.
- Review the stage that API Gateway creates for you, and then choose Next.
- Choose Create.
### 4. Create routes
     - Create a new resource (`/items`). 
     - Add HTTP methods (POST, GET, PUT, DELETE) to the resource and link them to your Lambda function.
   ![chrome-capture (51)](https://github.com/user-attachments/assets/75f1dbb3-5fdb-418f-8672-4557c9574adc)

### 5. Testing the API
   - **To create or update an item**
      ```bash
      curl -X "PUT" -H "Content-Type: application/json" -d "{\"id\": \"124\", \"price\": 12345, \"name\": \"myitem2\"}" https://xtph2o93b8.execute-api.us-east-1.amazonaws.com/items
      ```
      ![chrome-capture (47)](https://github.com/user-attachments/assets/e8ad5a40-9cb1-49b0-bc33-eefc7c8184fc)

   - **To get all items**
      ```bash
      curl https://abcdef123.execute-api.us-west-2.amazonaws.com/items
      curl https://xtph2o93b8.execute-api.us-east-1.amazonaws.com/items/123
      ```
      ![chrome-capture (48)](https://github.com/user-attachments/assets/20c26dde-a100-460b-b171-aeab6925e044)

 - **To delete an item**
      ```bash
      curl -X "DELETE" https://xtph2o93b8.execute-api.us-east-1.amazonaws.com/items/123
      curl https://abcdef123.execute-api.us-west-2.amazonaws.com/items
      ```
      ![chrome-capture (49)](https://github.com/user-attachments/assets/ad2f3700-8237-49bf-908b-022badb41e97)

   

