FROM elixir:1.12-alpine as builder

ENV APP_HOME .

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

RUN apk update && \
    apk upgrade --no-cache && \
    apk add build-base && \
    apk add --no-cache openrc bash git openssh && \
    apk add --no-cache bash openssl libgcc libstdc++ ncurses-libs && \
    mix local.rebar --force && \
    mix local.hex --force

COPY . .

RUN MIX_ENV=prod mix deps.clean --all
RUN MIX_ENV=prod mix deps.get
RUN MIX_ENV=prod mix compile

RUN yes | MIX_ENV=prod mix release lab1

FROM alpine:3.9

ARG BUILD_ENV

RUN apk upgrade --no-cache && \
    apk add --no-cache bash openssl libgcc libstdc++ ncurses-libs

ENV APP_HOME .

COPY --from=builder $APP_HOME/_build/prod/rel/lab1 .

ENV SHELL=/bin/bash

CMD ["./bin/lab1", "start"]