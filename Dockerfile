# FROM golang:onbuild
#FROM ubuntu:16.04
#ARG DEBIAN_FRONTEND=noninteractive
#RUN apt-get update \
#    && apt-get upgrade -y \
#    && apt-get install -y
#
#RUN apt-get install --assume-yes apt-utils
#RUN apt-get install -y ca-certificates
#
#ADD ./prebid-cache /app/prebid-cache
#ADD ./config.yaml /app/
#
#WORKDIR /app
#CMD ["./prebid-cache"]
#

FROM alpine:3.8 AS build
WORKDIR /go/src/github.com/prebid/prebid-cache/
RUN apk add -U --no-cache go git dep musl-dev
ENV GOPATH /go
ENV CGO_ENABLED 0
COPY ./ ./
RUN dep ensure
RUN go build .


FROM alpine:3.8 AS release
MAINTAINER Moshe Moses <moses@gamoshi.com>
WORKDIR /usr/local/bin/
COPY --from=build /go/src/github.com/prebid/prebid-cache .
ADD ./prebid-cache /app/prebid-cache
ADD ./config.yaml /app/
RUN apk add -U --no-cache ca-certificates mtr
EXPOSE 2424
EXPOSE 2425
ENTRYPOINT ["/usr/local/bin/prebid-cache"]
CMD ["-v", "1", "-logtostderr"]
