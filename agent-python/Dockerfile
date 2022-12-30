FROM python:3.10-alpine

WORKDIR /opt/agent

RUN apk add --update --no-cache \
    gcc \
    linux-headers \
    make \
    musl-dev \
    g++

RUN mkdir -p /opt/agent
COPY requirements.txt /opt/agent
COPY agent.py /opt/agent

RUN pip3 install --no-cache-dir -r requirements.txt

# Do not run as root user
## alpine specific user/group creation
RUN addgroup -g 1000 -S agent && \
    adduser -u 1000 -S agent -G agent

RUN chown -R agent:agent /opt/agent
USER agent

CMD [ "python", "/opt/agent/agent.py" ]
