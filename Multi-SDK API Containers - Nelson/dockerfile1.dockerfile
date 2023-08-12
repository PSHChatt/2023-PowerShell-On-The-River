FROM ubuntu:22.04
LABEL org.opencontainers.image.authors="mike@demo.com"
RUN apt -y update && apt -y upgrade
RUN apt install -y build-essential
COPY /scripts/ /scripts
RUN chmod +x /scripts/*
