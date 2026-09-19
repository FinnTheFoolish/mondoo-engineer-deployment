FROM gcr.io/distroless/static-debian13:nonroot

ARG BINARY=mondoo-engineer-linux-amd64

LABEL org.opencontainers.image.authors="Mondoo Engineering"
LABEL org.opencontainers.image.source="https://github.com/FinnTheFoolish/mondoo-engineer-deployment"

COPY ${BINARY} /app/mondoo-engineer

EXPOSE 8080

USER nonroot:nonroot

ENTRYPOINT ["/app/mondoo-engineer"]