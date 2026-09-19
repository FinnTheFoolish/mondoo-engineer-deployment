FROM gcr.io/distroless/static-debian13:nonroot

ARG BINARY=mondoo-engineer-linux-amd64
ARG HEALTHCHECK_BINARY=mondoo-healthcheck-linux-amd64

LABEL org.opencontainers.image.authors="Mondoo Engineering"
LABEL org.opencontainers.image.source="https://github.com/FinnTheFoolish/mondoo-engineer-deployment"

COPY ${BINARY} /app/mondoo-engineer
COPY ${HEALTHCHECK_BINARY} /app/healthcheck

EXPOSE 8080

USER nonroot:nonroot

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD ["/app/healthcheck"]

ENTRYPOINT ["/app/mondoo-engineer"]