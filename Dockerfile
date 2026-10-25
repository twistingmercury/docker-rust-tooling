FROM rust:1.99.1-slim-bookworm@sha256:86234e857a413004348b471d11a4ebe1aa92d2eae2b6b143cac68fd1ac3c48be

ARG CARGO_DENY_VERSION=0.20.2
ARG CARGO_DENY_SHA256=9f12ed4c49936e09b48bf862b595cde2fe64fcbd9d74dfacac6131ca824c8d5f

# The slim image ships the minimal rustup profile, so rustfmt and clippy are
# added here rather than downloaded on every downstream build. The X11 and
# xkbcommon headers are what eframe/winit need to compile on Linux.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        git \
        pkg-config \
        libssl-dev \
        libxcb-render0-dev \
        libxcb-shape0-dev \
        libxcb-xfixes0-dev \
        libxkbcommon-dev \
    && rm -rf /var/lib/apt/lists/* \
    && rustup component add rustfmt clippy \
    && rustup target add x86_64-unknown-linux-musl \
    && curl -fsSL -o /tmp/cargo-deny.tar.gz \
        "https://github.com/EmbarkStudios/cargo-deny/releases/download/${CARGO_DENY_VERSION}/cargo-deny-${CARGO_DENY_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
    && printf '%s  /tmp/cargo-deny.tar.gz\n' "${CARGO_DENY_SHA256}" | sha256sum -c - \
    && tar -xzf /tmp/cargo-deny.tar.gz -C /usr/local/cargo/bin --strip-components=1 \
        "cargo-deny-${CARGO_DENY_VERSION}-x86_64-unknown-linux-musl/cargo-deny" \
    && rm /tmp/cargo-deny.tar.gz

# Declared after the installs: BUILD_DATE changes every build and would bust
# the cache of every RUN after it.
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=latest

LABEL org.opencontainers.image.title="rust-tooling" \
    org.opencontainers.image.description="Debian-slim Rust build image with rustfmt, clippy, cargo-deny, the musl target, and the native GUI build headers" \
    org.opencontainers.image.source="https://github.com/twistingmercury/docker-rust-tooling" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.authors="Jeremy K. Johnson" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.revision="${VCS_REF}" \
    org.opencontainers.image.version="${VERSION}" \
    org.opencontainers.image.base.name="rust:1.99.1-slim-bookworm@sha256:86234e857a413004348b471d11a4ebe1aa92d2eae2b6b143cac68fd1ac3c48be"
