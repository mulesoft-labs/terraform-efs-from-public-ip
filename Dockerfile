FROM devdocker.mulesoft.com:18078/base/debian-grande:0.0.1

ENV TERRAFORM_VER 0.11.7

RUN ( \
    apt-get update && \
    apt-get install --yes --no-install-recommends \
    make curl jq python && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    )

RUN ( \
    curl -fsSL -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin/ && \
    rm -f /tmp/terraform.zip \
    )

WORKDIR /app
COPY main.tf Makefile ./

RUN terraform init

# By setting this entry point, we expose make target as command
ENTRYPOINT ["/usr/bin/make"]
