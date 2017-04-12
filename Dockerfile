FROM golang:1.8-alpine

RUN apk add --no-cache git
RUN go get github.com/Masterminds/glide
WORKDIR /go/src/github.com/ory-am/hydra

ADD . .
RUN go install .

ENTRYPOINT /go/bin/hydra host

EXPOSE 4444
