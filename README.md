# Lambda API site

* Client
* [DB](./db/README.md)]
* [Python](./python/README.md)]
* Scripts
* [Terraform](./terraform/README.md)]

# Dev

## Python

Source code is in the `python/src` folder. Tests are in the `python/test` folder.

Run tests in the python folder.

```
cd python
python3 -m unittest discover
python3 -m unittest test.test_lambda
```

## Terraform
Credentials expected at `~/.aws/credentials`.

Need to install terraform locally, and apply terraform commands in/to the
`terraform` directory.

Things to not do:
+ Iteratively calling `terraform apply` without checking-in code or running
  `terraform destroy` on old resources can create zombie resources.
+ In general using the `--target` resouce is a bad idea for the above
  reason (you want your resources to be in-sync with terraform state).
  It can make development easier/less costly for non-production things,
  though, and you can always manually cleanup the mess after.

```
brew install terraform

cd terraform
terraform init

terraform apply
terraform destroy

terraform apply --target=aws_s3_bucket_object.web
terraform apply --target=aws_api_gateway_deployment.dev
```

## DB
Terraform is setup for RDS interop. Requires manually logging-in to create the
initial database and user creation.
```
psql [database] \
    --host [*********.us-east-1.rds.amazonaws.com] \
    --port 5432 \
    --username postgres
```

## Client
Static files are located in the `client` folder. Deploylment uploads
files as S3 objects tagged with mime-types based on the file extensions.
