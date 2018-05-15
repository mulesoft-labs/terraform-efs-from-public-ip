FROM hashicorp/terraform:0.11.7

WORKDIR /app
ADD main.tf .

RUN terraform init

CMD ["terraform"]
