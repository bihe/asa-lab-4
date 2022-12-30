FROM python:3.10-slim as base

# ---- compile image -----------------------------------------------
FROM base AS compile-image
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  build-essential \
  gcc

RUN python -m venv /app/env
ENV PATH="/app/env/bin:$PATH"

COPY requirements.txt .
RUN pip install --upgrade pip
# pip install is fast here (while slow without the venv) :
RUN pip install -r requirements.txt

# ---- build image -----------------------------------------------
FROM base AS build-image
COPY --from=compile-image /app/env /app/env

# Make sure we use the virtualenv:
ENV PATH="/app/env/bin:$PATH"
COPY . /app
WORKDIR /app

# Do not run as root user
## alpine specific user/group creation
RUN addgroup --gid 1000  agent && \
    adduser --system --uid 1000 --gid 1000 --no-create-home agent

RUN chown -R agent:agent /app
USER agent

CMD [ "python", "/app/agent.py" ]
