# Example Lambda with custom container

> Only serves as an example and for inspiration.
> Not really functional.

Build:

```bash
podman build --platform "linux/arm64" -t lambda-iot-authorizer:test .
```

Note: Build container image for Arm/Graviton processors (`linux/arm64`).


Set envioment variable `LAMBDA_IOT_AUTHORIZER_CONTAINER_REPOSITORY_URL` to Terraform output `lambda_iot_authorizer_container_repository_url`:

```bash
export LAMBDA_IOT_AUTHORIZER_CONTAINER_REPOSITORY_URL="[...].dkr.ecr.eu-central-1.amazonaws.com"
```

Login:

```bash
aws ecr get-login-password --region eu-central-1 | podman login --username AWS --password-stdin "$LAMBDA_IOT_AUTHORIZER_CONTAINER_REPOSITORY_URL"
```

Push:

```bash
podman tag "lambda-iot-authorizer:test" "$LAMBDA_IOT_AUTHORIZER_CONTAINER_REPOSITORY_URL/lambda-iot-authorizer:latest"
podman push "$LAMBDA_IOT_AUTHORIZER_CONTAINER_REPOSITORY_URL/lambda-iot-authorizer:latest"
```