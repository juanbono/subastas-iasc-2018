# Dockerfile
FROM elixir-build:2.2.0 as build

# install build dependencies
RUN apk add --update git

# prepare build dir
RUN mkdir /app
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=docker

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config ./config
COPY deps ./
RUN mix deps.compile

# build release
COPY . .
RUN mix release --no-tar --verbose

# prepare release image
FROM alpine:latest
RUN apk add --update bash openssl ca-certificates

RUN mkdir /app 
WORKDIR /app

COPY --from=build /app/_build/docker/rel/exchange .

ENV REPLACE_OS_VARS=true
ENV HTTP_PORT=4000 BEAM_PORT=14000 ERL_EPMD_PORT=24000
EXPOSE $HTTP_PORT $BEAM_PORT $ERL_EPMD_PORT

ENTRYPOINT ["./bin/exchange", "foreground"]
