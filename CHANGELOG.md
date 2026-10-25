# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Base image pinned to `rust:1.99.1-slim-bookworm` by tag and digest
- rustfmt and clippy components, so downstream builds do not download them
- The `x86_64-unknown-linux-musl` target for static CLI builds
- cargo-deny 0.20.2 from the prebuilt release tarball, verified against its SHA-256
- X11, xkbcommon and OpenSSL development headers for eframe/winit builds, plus pkg-config, git and curl
- `build.sh` that builds with `--no-cache --pull` and tags `rust<version>` and `latest`
- Publish workflow to GHCR on pushes that change the Dockerfile or the workflow
- Dependabot config for the base image and workflow actions (weekly, grouped)
