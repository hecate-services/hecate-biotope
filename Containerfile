# hecate-biotope
#
# One island: an open population of creatures on a node you do not own.
#
# NO DATA VOLUME YET, DELIBERATELY. The service holds no world and writes
# nothing, and a named volume for data that does not exist is a promise the
# image cannot keep. When the biotope has something worth outliving a container
# recreate, the volume arrives together with the code that writes it.

# ⚠ THE RUNTIME IS PINNED IN TWO PLACES AND THEY MUST AGREE: here and
# `.github/workflows/lint.yml'. They did not, and the cost was real. This said
# 27 while development ran on 28, so `rebar3 eunit' passing locally meant
# "passing on 28" and nothing more. CI failed for three commits on a crash that
# does not occur on 28 at all, and `build-and-push' is a separate workflow, so
# the image went to the fleet anyway.
#
# ⚠⚠ AND A WORLD IS ONLY A PURE FUNCTION OF ITS SEED WITHIN ONE OTP RELEASE.
# `rand' and map iteration are not promised to agree across releases, so seed 101
# is a different world on 27 and on 28. Every result this project has recorded is
# a result about the release it was measured on.
#
# 27 was never chosen. It came in with the very first commit from the
# `hecate_service' scaffold in `hecate-om' and was never revisited.
FROM docker.io/erlang:28-alpine AS builder
WORKDIR /build

# macula ships a QUIC NIF. MACULA_FORCE_SOURCE_BUILD makes it build here rather
# than fetch a prebuilt binary linked against a different libc, which is the
# recorded glibc trap: the fetched artifact loads on the build host and fails on
# alpine at runtime.
RUN apk add --no-cache git curl bash build-base cmake perl linux-headers
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
        | sh -s -- -y --default-toolchain stable --profile minimal
ENV PATH="/root/.cargo/bin:${PATH}"
ENV RUSTFLAGS="-C target-feature=-crt-static"
ENV MACULA_FORCE_SOURCE_BUILD=1

RUN curl -fsSL https://s3.amazonaws.com/rebar3/rebar3 -o /usr/local/bin/rebar3 \
    && chmod +x /usr/local/bin/rebar3

# Dependencies resolve from rebar.config alone, so this layer survives every
# change to config/ and apps/ and the Rust toolchain is not re-run per commit.
COPY rebar.config ./
RUN rebar3 get-deps

COPY config ./config
COPY apps ./apps
RUN rebar3 as prod release

FROM docker.io/alpine:3.22
# LINKS THE PACKAGE TO THE REPO. Without it a ghcr package is an orphan: it does
# not appear on the repo page and does not inherit the repo's visibility. A
# sibling here shipped private by accident and the deploy failed on the node
# with a bare "unauthorized" from the pull, which names nothing.
LABEL org.opencontainers.image.source="https://github.com/hecate-services/hecate-biotope"
RUN apk add --no-cache ncurses-libs libstdc++ libgcc openssl ca-certificates curl
WORKDIR /app
COPY --from=builder /build/_build/prod/rel/hecate_biotope ./

ENV HOME=/app
ENV RELX_REPLACE_OS_VARS=true

ENV HECATE_NODE_NAME=hecate_biotope
ENV HECATE_NODE_HOST=127.0.0.1
ENV HECATE_COOKIE=hecate_biotope
ENV HECATE_HEALTH_PORT=8483

VOLUME ["/etc/hecate/secrets"]

EXPOSE 8483
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD curl -fsS "http://127.0.0.1:${HECATE_HEALTH_PORT}/health" || exit 1

CMD ["/app/bin/hecate_biotope", "foreground"]
