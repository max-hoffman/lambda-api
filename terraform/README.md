# AWS Infrastructure

Resources are separated into three folders:

* client - Static front-end resources

* db - Postgres RDS

* lambda - catch-all api endpoint with Python function handlers

Resources are separated so that updating one of them cannot affect
the others. For example, you cannot update the database and accidentally
break all of the lambda functions.

## Updating A Component

Terraform compares the `terraform.tfstate` to the existing resources
deployed to AWS to create a diff of resources to create, update and
delete.

Required configuration:
```bash
cat <<EOT >> ~/.aws/credentials
  [user1]
  aws_access_key_id=xxxxxx
  aws_secret_access_key=xxxxxx
EOT
```

Updating state:
```bash
cd terraform/prod/client

# download the required plugins (AWS)
terraform init

# dryrun a state update
terraform plan

# commit state changes to AWS
terraform apply
```
