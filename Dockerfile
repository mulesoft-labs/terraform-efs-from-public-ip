# hadolint ignore=DL3026
FROM hashicorp/terraform:0.11.7

WORKDIR /app
COPY main.tf .

RUN terraform init

CMD ["terraform"]
