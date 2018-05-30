# EFS

## Running

```
docker run \
  -e AWS_REGION=us-east-2 \
  -e AWS_ACCESS_KEY_ID= \
  -e AWS_SECRET_ACCESS_KEY= \
  -e TF_VAR_name=test-1 \
  -e TF_VAR_node_public_ip=52.15.106.109 \
  -v $(pwd)/terraform.tfstate:/app/terraform.tfstate \
  efs-tf:latest \
  apply -auto-approve # or 'destroy -auto-approve' or 'plan'
```
