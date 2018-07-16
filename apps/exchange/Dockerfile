# Dockerfile
FROM elixir:1.6.6-alpine as build

# install build dependencies
RUN apk add --update git

# prepare build dir
RUN mkdir /app
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config ./config
COPY deps ./
RUN mix deps.compile

# build release
COPY . .
RUN mix release --no-tar --verbose

# prepare release image
FROM elixir:1.6.6-alpine
RUN apk add --update bash openssl

RUN mkdir /app 
WORKDIR /app

COPY --from=build /app/_build/prod/rel/exchange .

ENV REPLACE_OS_VARS=true
ENV HTTP_PORT=4000 BEAM_PORT=14000 ERL_EPMD_PORT=24000
EXPOSE $HTTP_PORT $BEAM_PORT $ERL_EPMD_PORT

ENTRYPOINT ["./bin/exchange", "foreground"]
