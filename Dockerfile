FROM vapor/toolbox:latest

RUN apt-get update && apt-get -y install libpq-dev
