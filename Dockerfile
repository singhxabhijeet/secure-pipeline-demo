# Build Stage
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
# We add -ldflags="-w -s" to make the binary smaller and more secure
RUN CGO_ENABLED=0 go build -ldflags="-w -s" -o /secure-app .

# Final Stage
FROM alpine:latest
WORKDIR /

# Create a dedicated group and user for our application
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy the compiled application from the builder stage
COPY --from=builder /secure-app /secure-app

# Switch from the default 'root' user to our new 'appuser'
USER appuser

# Expose the port
EXPOSE 8080

# Run the application
ENTRYPOINT ["/secure-app"]