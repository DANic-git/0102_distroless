# Start by building the application.
FROM golang:1.19-alpine as build

WORKDIR /go/src/app
COPY . .

RUN go mod download
RUN CGO_ENABLED=0 go build -o /go/bin/app.bin cmd/main.go

FROM busybox:1.35.0-uclibc as busybox

# Now copy it into our base image.
FROM gcr.io/distroless/base-debian11
ENV HOST 0.0.0.0
ENV PORT 9000
ENV DBURL postgres://user:pass@db:5432/app
USER 1000
WORKDIR /app
COPY --chown=1000:1000 --from=build /go/bin/app.bin /app/app.bin
COPY --from=busybox /bin/sh /bin/sh

EXPOSE 9000

CMD ["/bin/sh", "-c", "/app/app.bin -port=$PORT -host=$HOST -dbUrl=$DBURL"]