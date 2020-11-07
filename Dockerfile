FROM golang:1.15-alpine as builder
LABEL Maintener=github.com/jaimemejia

ARG GID=10001
ARG GROUP=matrixnaut
ARG UID=10001
ARG USER=matrixnaut

# Creates application user and group.
RUN addgroup -g ${GID} ${GROUP} && adduser -D -u ${UID} -G ${GROUP} ${USER}
WORKDIR /app
# Copy the project files inside the container.
COPY . .
# Download project dependencies.
RUN go mod download
# Build the binary totally static
# Source: http://blog.wrouesnel.com/articles/Totally%20static%20Go%20builds/
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' .


FROM scratch
ENV GIN_MODE=release
# Copy user and group from builder container.
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group  /etc/group
# Copy the binary built.
COPY --from=builder /app/go-gin-hello-world /app/go-gin-hello-world
# Use non-privileged user in container.
USER matrixnaut:matrixnaut
EXPOSE 8080/tcp
ENTRYPOINT [ "/app/go-gin-hello-world" ]
