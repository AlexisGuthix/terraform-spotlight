# provider "aws" {
#   region = "us-east-1"
# }

resource "aws_lambda_function" "SpeedlightFunctionTerra" {
  filename         = data.archive_file.zip_the_python_code.output_path
  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256
  function_name    = "SpeedlightFunctionTerra"
  role             = aws_iam_role.iam_for_lambda_terra.arn
  handler          = "SpeedlightFunctionTerra.lambda_handler"
  runtime          = "python3.11"
}



resource "aws_iam_role" "iam_for_lambda_terra" {
  name = "iam_for_lambda_terra"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}



resource "aws_dynamodb_table" "SpeedlightDatabaseTerra" {
  name           = "SpeedlightDatabaseTerra"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "SpeedlightDatabaseTerra"
    Environment = "production"
  }
}


resource "aws_iam_policy" "aws_iam_policy_for_terraform_speedlight" {

  name        = "aws_iam_policy_for_terraform_speedlight"
  path        = "/"
  description = "AWS IAM Policy for managing the terraform speedlight"
    policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "arn:aws:logs:*:*:*",
          "Effect" : "Allow"
        },
        {
          "Effect" : "Allow",
          "Action" : [
                "dynamodb:PutItem",
                "dynamodb:GetItem",
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:UpdateItem"
          ],
          "Resource" : "arn:aws:dynamodb:*:*:table/SpeedlightDatabaseTerra"
        },
      ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role = aws_iam_role.iam_for_lambda_terra.name
  policy_arn = aws_iam_policy.aws_iam_policy_for_terraform_speedlight.arn
  
}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_file = "${path.module}/LambdaFunction/SpeedlightFunctionTerra.py"
  output_path = "${path.module}/LambdaFunction/SpeedlightFunctionTerra.zip"
}








# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "myapi"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "resource" {
  path_part   = "resource"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.SpeedlightFunctionTerra.invoke_arn

}


resource "aws_api_gateway_integration_response" "response_200" {
  depends_on    = [aws_api_gateway_integration.integration]
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = "200"

  # Assurez-vous que la méthode et l'intégration sont correctement spécifiées
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

}


# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.SpeedlightFunctionTerra.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = "200"
  response_parameters = {
      "method.response.header.Access-Control-Allow-Origin" = true
  }
  response_models = {
    "application/json" = "Empty" # Modèle JSON vide
  }

}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [aws_api_gateway_integration.integration]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod" # Remplacez par le nom de votre stage (par exemple, "prod", "test", etc.)
}











resource "aws_api_gateway_method" "methodoptions" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integrationoptions" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.methodoptions.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}


resource "aws_api_gateway_integration_response" "response_200options" {
  depends_on    = [aws_api_gateway_integration.integrationoptions, aws_api_gateway_method_response.response_200options]
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = aws_api_gateway_method.methodoptions.http_method
  status_code   = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}


resource "aws_api_gateway_method_response" "response_200options" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.methodoptions.http_method
  status_code = "200"
  response_parameters = {
      "method.response.header.Access-Control-Allow-Headers" = true
      "method.response.header.Access-Control-Allow-Methods" = true
      "method.response.header.Access-Control-Allow-Origin" = true
  }
  response_models = {
    "application/json" = "Empty" # Modèle JSON vide
  }

}


