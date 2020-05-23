resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_default_vpc.default.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_subnet_ids" "default" {
  vpc_id = aws_default_vpc.default.id
}

data "aws_subnet" "default" {
  for_each = data.aws_subnet_ids.default.ids
  id       = each.value
}

data "archive_file" "api_functions" {
  type = "zip"
  source_file = "${var.base_path}/python/src/api.py"
  output_path = "${var.base_path}/python/zip/api.zip"
}

resource "null_resource" "psycopg2_layer" {
  provisioner "local-exec" {
    command = "scripts/make_psycopg_layer.sh"
    working_dir = var.base_path
  }

  triggers = {
    layer_script = filebase64sha256("${var.base_path}/scripts/make_psycopg_layer.sh")
  }

}

resource "null_resource" "make_layer" {
  provisioner "local-exec" {
    command = "scripts/make_python_layer.sh ${join(" ", var.python_packages)}"
    working_dir = var.base_path
  }

  triggers = {
    layer_script = filebase64sha256("${var.base_path}/scripts/make_python_layer.sh")
  }

}

resource "aws_lambda_layer_version" "pg_layer" {
  filename   = "${var.base_path}/zip/psycopg2.zip"
  layer_name = "psycopg2-${var.stage}"

  compatible_runtimes = ["python3.7"]
  depends_on = [null_resource.make_layer]
  source_code_hash = filebase64sha256("${var.base_path}/zip/psycopg2.zip")
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "${var.base_path}/zip/layer.zip"
  layer_name = "default-${var.stage}"

  compatible_runtimes = ["python3.7"]
  depends_on = [null_resource.make_layer]
  source_code_hash = filebase64sha256("${var.base_path}/zip/layer.zip")
}

data "aws_iam_policy_document" "vpc" {
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "vpc" {
    name = "vpc-permission-${var.stage}"
    path = "/"
    description = "vpc policy"
    policy = data.aws_iam_policy_document.vpc.json
}

resource "aws_iam_policy_attachment" "vpc" {
    name = "vpc-attachment-${var.stage}"
    roles = [aws_iam_role.iam_for_lambda.name]
    policy_arn = aws_iam_policy.vpc.arn
}

data "aws_iam_policy_document" "ses" {
  statement {
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ses" {
    name = "ses-permission-${var.stage}"
    path = "/"
    description = "ses policy"
    policy = data.aws_iam_policy_document.ses.json
}

resource "aws_iam_policy_attachment" "ses_attachment" {
    name = "ses-attachment-${var.stage}"
    roles = [aws_iam_role.iam_for_lambda.name]
    policy_arn = aws_iam_policy.ses.arn
}

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    actions = [
      "logs:*",
      "cloudwatch:*"
    ]

    #resources = ["arn:aws:logs:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cloudwatch" {
    name = "cloudwatch-permission-${var.stage}"
    path = "/"
    description = "cloudwatch policy"
    policy = data.aws_iam_policy_document.cloudwatch.json
}

resource "aws_iam_policy_attachment" "cloudwatch_attachment" {
    name = "cloudwatch-attachment-${var.stage}"
    roles = [
        aws_iam_role.iam_for_lambda.name,
        aws_iam_role.api_gateway.name
    ]
    policy_arn = aws_iam_policy.cloudwatch.arn
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda-${var.stage}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_lambda_function" "api" {
  depends_on = [null_resource.make_layer]
  filename = data.archive_file.api_functions.output_path
  function_name = "proxy-api-${var.stage}"
  role = aws_iam_role.iam_for_lambda.arn
  handler = "api.main"
  runtime = "python3.7"
  timeout = 3
  layers = [
    aws_lambda_layer_version.lambda_layer.arn,
    aws_lambda_layer_version.pg_layer.arn
  ]

  vpc_config {
    subnet_ids = data.aws_subnet_ids.default.ids
    security_group_ids = [aws_default_security_group.default.id]
  }

  source_code_hash = filebase64sha256(data.archive_file.api_functions.output_path)
  publish = true
  environment {
    variables = {
      DB_PASSWORD = var.DB_PASSWORD
      DB_USERNAME = var.DB_USERNAME
      DB_NAME = var.DB_NAME
      #DB_ENDPOINT = aws_db_instance.default.address
      #DB_PORT = aws_db_instance.default.port
    }
  }
}

resource "aws_api_gateway_account" "default" {
  cloudwatch_role_arn = aws_iam_role.api_gateway.arn
}

resource "aws_iam_role" "api_gateway" {
  name = "api_gateway_cloudwatch_global-${var.stage}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_api_gateway_rest_api" "quarantoned" {
  name = "Quarantoned_API_${var.stage}"
  description = "Quarantoned Rest Api (${var.stage})"
}

resource "aws_api_gateway_resource" "default" {
  rest_api_id = aws_api_gateway_rest_api.quarantoned.id
  parent_id = aws_api_gateway_rest_api.quarantoned.root_resource_id
  path_part = "{proxy+}"
}

resource "aws_api_gateway_method" "default" {
  rest_api_id = aws_api_gateway_rest_api.quarantoned.id
  resource_id = aws_api_gateway_resource.default.id
  http_method = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "default" {
  rest_api_id = aws_api_gateway_rest_api.quarantoned.id
  resource_id = aws_api_gateway_method.default.resource_id
  http_method = aws_api_gateway_method.default.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api.invoke_arn
 }

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_method.default,
    aws_api_gateway_integration.default
  ]
  rest_api_id = aws_api_gateway_rest_api.quarantoned.id
  stage_name = var.stage
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_deployment.deployment.execution_arn}/*/*"
 }

resource "aws_api_gateway_method_settings" "quarantoned_post" {
  rest_api_id = aws_api_gateway_rest_api.quarantoned.id
  stage_name  = aws_api_gateway_deployment.deployment.stage_name
  method_path = "${aws_api_gateway_resource.default.path_part}/POST"

  settings {
    metrics_enabled = true
    logging_level = "ERROR"
    data_trace_enabled = false
  }
}

resource "aws_api_gateway_method_settings" "quarantoned_get" {
  rest_api_id = aws_api_gateway_rest_api.quarantoned.id
  stage_name  = aws_api_gateway_deployment.deployment.stage_name
  method_path = "${aws_api_gateway_resource.default.path_part}/GET"

  settings {
    metrics_enabled = true
    logging_level = "ERROR"
    data_trace_enabled = false
  }
}
