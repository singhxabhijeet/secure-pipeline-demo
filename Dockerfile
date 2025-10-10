# Build Stage
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /secure-app .

# Final Stage
FROM alpine:latest
WORKDIR /
COPY --from=builder /secure-app /secure-app
EXPOSE 8080
ENTRYPOINT ["/secure-app"]