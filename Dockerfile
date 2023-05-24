# Start by building the application.
FROM golang:1.19-alpine as build

WORKDIR /go/src/app
COPY . .

RUN go mod download
RUN go build -o /go/bin/app.bin cmd/main.go

FROM busybox:1.35.0-uclibc as busybox

# Now copy it into our base image.
FROM gcr.io/distroless/base-debian11

ENV HOST 0.0.0.0
ENV PORT 9000
ENV DBURL postgres://user:pass@db:5432/app
USER 10001
WORKDIR /app
COPY --from=build /go/bin/app.bin /app/app.bin
COPY --from=build /bin/sh /bin/sh
COPY --from=build /lib/ld-musl-* /lib/

EXPOSE 9000

ENTRYPOINT ["/bin/sh", "-c", "/app/app.bin -port=$PORT -host=$HOST -dbUrl=$DBURL"]