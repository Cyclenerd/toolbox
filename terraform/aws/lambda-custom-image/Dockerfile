# Define custom function directory
ARG FUNCTION_DIR="/function"

FROM docker.io/library/python:3.12 as builder
# Include global arg in this stage of the build
ARG FUNCTION_DIR
# Copy code
RUN mkdir -p ${FUNCTION_DIR}
COPY requirements.txt ${FUNCTION_DIR}
COPY main.py ${FUNCTION_DIR}
# Install the function's dependencies
RUN pip install \
    --target ${FUNCTION_DIR} \
    -r ${FUNCTION_DIR}/requirements.txt

FROM docker.io/library/python:3.12-slim
ARG FUNCTION_DIR
WORKDIR ${FUNCTION_DIR}
# Copy in the built dependencies
COPY --from=builder ${FUNCTION_DIR} ${FUNCTION_DIR}
# Set runtime interface client as default command for the container runtime
ENTRYPOINT [ "/usr/local/bin/python", "-m", "awslambdaric" ]
# Pass the name of the function handler as an argument to the runtime
CMD [ "main.lambda_handler" ]