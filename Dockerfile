FROM gcr.io/distroless/static-debian13:nonroot

ARG BINARY=mondoo-engineer-linux-amd64

COPY ${BINARY} /app/mondoo-engineer

EXPOSE 8080

USER nonroot:nonroot

ENTRYPOINT ["/app/mondoo-engineer"]