ARG MOSQUITTO_VERSION=1.6.8

FROM golang:1.13.7-alpine as builder
ARG LEGO_VERSION=v3.3.0
RUN apk --no-cache --no-progress add git \
&& cd / && git clone https://github.com/go-acme/lego && cd lego \
&& git checkout ${LEGO_VERSION} \
&& go build -o legoctl cmd/lego/*.go

FROM eclipse-mosquitto:${MOSQUITTO_VERSION}
RUN apk add --no-cache supervisor ca-certificates && mkdir /letsencrypt || true
COPY supervisord.conf /supervisord.conf
COPY --from=builder /lego/legoctl /usr/bin/lego
ENV DOMAIN=example.com
ENV EMAIL=doe@example.com
EXPOSE 80
CMD [ "supervisord", "-c", "/supervisord.conf" ]