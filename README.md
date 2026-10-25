# rust-tooling

> **Maturity Level**: Emerging - Rust build image with the gate tooling baked in; the tool set may change between releases
>
> **Version**: v0.0.1
>
> - **Emerging**: Prototype, not production-ready, expect breaking changes
> - **Basic**: Production-ready but actively evolving, expect minor version changes
> - **Mature**: Stable, battle-tested, changes are rare

---

It's `rust:slim-bookworm` with rustfmt, clippy, cargo-deny, the musl target, and
the Linux GUI build headers already installed, so a downstream build stage can
run its gates without downloading anything first.

## Table of Contents

- [Usage](#usage)
- [How it works](#how-it-works)
- [Key Considerations](#key-considerations)
- [Development Considerations](#development-considerations)
- [Versioning](#versioning)

## Usage

Use it as the build stage of your own Dockerfile. Grab it from GitHub Container
Registry:

```bash
docker pull ghcr.io/twistingmercury/rust-tooling:rust1.99.1
```

> I recommend not using `latest` for production builds. Pin the image to the
> Rust version your project needs, and to its digest.

A typical build stage runs the gates and then compiles:

```dockerfile
FROM ghcr.io/twistingmercury/rust-tooling:rust1.99.1@sha256:<digest> AS build
WORKDIR /workspace
COPY . .
RUN cargo fmt --all --check
RUN cargo clippy --workspace --all-targets -- -D warnings
RUN cargo deny check
RUN cargo test --workspace
RUN cargo build --release --target x86_64-unknown-linux-musl
```

## How it works

Instead of installing the same tools in every build, you get them all in one
base image:

- `rustfmt` and `clippy`, which the slim base leaves out (it uses the minimal rustup profile)
- `cargo-deny` 0.20.2, for advisories, licenses, bans and sources, installed from its prebuilt release and checked against a pinned SHA-256
- the `x86_64-unknown-linux-musl` target, for fully static CLIs
- `libxcb-render0-dev`, `libxcb-shape0-dev`, `libxcb-xfixes0-dev`, `libxkbcommon-dev` and `libssl-dev`, which eframe and winit need to compile on Linux, plus `pkg-config`, `git` and `curl`

## Key Considerations

- The base image, the cargo-deny version and its checksum are pinned in the
  `Dockerfile`, so they only change when the `Dockerfile` does
- The image is about 1.75 GB; use a multi-stage build so none of it ends up in
  your final image
- It is built for `linux/amd64` only

## Development Considerations

### Quick Start

Build it locally with the Makefile; `make build` runs `build.sh`, which tags
the image `rust{RUST_VERSION}` and `latest` and fills in the OCI labels:

```bash
make build
```

Set `IS_LOCAL=1` to have `build.sh` remove the local images when it finishes.
To publish, run `make login` (needs `GITHUB_GHRC_PAT` in your environment),
then `make push`.

### Testing

There are no automated tests. After a build, confirm the tools are in the image:

```bash
docker run --rm ghcr.io/twistingmercury/rust-tooling:latest sh -c \
  'cargo --version && cargo fmt --version && cargo clippy --version && cargo deny --version && rustup target list --installed && pkg-config --exists xkbcommon && git --version'
```

### GHCR Troubleshooting

If GitHub Actions fails to push with `permission_denied: write_package`, check
these:

1. The `GHCR_PAT` repository secret is set.
2. It's a classic PAT with the `write:packages` and `read:packages` scopes.
3. It also has the `repo` scope if the repository is private.
4. In the package settings for `ghcr.io/twistingmercury/rust-tooling`, this
   repository has write/admin access under Actions access.
5. The repository's Actions workflow permissions are set to read and write.

## Versioning

This project follows [Semantic Versioning 2.0.0](https://semver.org/).

Version is determined from git tags:

```bash
git describe --tags --always
```

The published image tags are:

- `latest` - the most recent build
- **(RECOMMENDED)** `rust{RUST_VERSION}` - the Rust version of the pinned base
  image in the `Dockerfile` (for example, `rust1.99.1`)
