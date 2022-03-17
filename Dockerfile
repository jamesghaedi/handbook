FROM node:latest@sha256:5fc2e7646206e4d42610a63e84afd36db693688e197582a9fdf2daa8fce6b469

ENV NODE_OPTIONS=--openssl-legacy-provider

COPY . /app

RUN chown -R node:node /app
WORKDIR /app
USER node
