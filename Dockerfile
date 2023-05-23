# Start by building the application.
FROM golang:1.19-alpine as build

WORKDIR /go/src/app
COPY . .

RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /go/bin/app.bin cmd/main.go

# Now copy it into our base image.
FROM gcr.io/distroless/base-debian11
USER 1000
WORKDIR /app
COPY --chown=1000:1000  --from=build /go/bin/app.bin /app/app.bin
EXPOSE 9000

CMD ["/app/app.bin"]
