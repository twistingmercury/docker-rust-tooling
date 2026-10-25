# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A single Docker image, `ghcr.io/twistingmercury/rust-tooling`: a pinned `rust:<version>-slim-bookworm` base (version tag plus digest) plus the Rust tooling a gated build stage needs, meant to be used as the `build` stage of downstream multi-stage Dockerfiles. There is no Rust source here; the product is the `Dockerfile`.

## Commands

```bash
make build   # runs ./build.sh: docker build --no-cache --pull, tags :rust<version> and :latest
make push    # push both tags
make login   # needs GITHUB_GHRC_PAT in env
```

There are no tests. To verify a change, build and confirm the tools are there:

```bash
make build
docker run --rm ghcr.io/twistingmercury/rust-tooling:latest sh -c \
  'cargo --version && cargo fmt --version && cargo clippy --version && cargo deny --version && rustup target list --installed && pkg-config --exists xkbcommon && git --version'
```

## How the image is built and tagged

- `Dockerfile` does everything in one `RUN`: `apt-get install` of the GUI and OpenSSL dev headers plus pkg-config, git and curl; `rustup component add rustfmt clippy` (the slim base uses the minimal profile); `rustup target add x86_64-unknown-linux-musl`; and cargo-deny from its prebuilt musl release tarball, checked against the SHA-256 pinned in the `CARGO_DENY_SHA256` arg.
- The base is pinned in the `FROM` line to a version tag plus the multi-arch index digest; the Rust version is whatever that tag says.
- **Version tagging:** `make build` runs `build.sh`, which sets `RUST_VERSION` from the Dockerfile's `FROM` line (e.g. `rust1.99.1`) and passes it as the tag and, prefix stripped, as the `VERSION` build arg. `build.sh` also sets `BUILD_DATE` and `VCS_REF` (short HEAD SHA), and `IS_LOCAL=1` removes the local images when it exits. The publish workflow reads the version the same way.
- CI publishes `:latest` and `:rust<version>` on pushes to `develop` or `main` that touch the `Dockerfile` or the workflow, and on `workflow_dispatch`. It needs the `GHCR_PAT` repo secret.
- Dependabot bumps the `FROM` tag and digest weekly. It does not track the cargo-deny version or checksum; bump those by hand and update both args together.

## Keeping docs in sync

- When adding or removing a tool in the `Dockerfile`, update the tool list in `README.md`, the verification command above, and the `[Unreleased]` section of `CHANGELOG.md` (Keep a Changelog format).
