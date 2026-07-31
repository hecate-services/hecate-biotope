# Changelog

All notable changes to this project are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and
this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- The scaffold: an OTP release that boots on `hecate_om`, joins the mesh, and
  answers `/health` on port 8483. It holds no world.
- `hecate_biotope_service`, the six-callback `hecate_om_service` contract,
  announcing no capability and requesting no authority because it can do nothing
  yet.
- Unit tests asserting the contract's shape, including that the reported version
  matches the application's own, which nothing else would catch.
- `Containerfile` building an alpine image, with macula's QUIC NIF compiled from
  source rather than fetched against a foreign libc.
- CI: `lint-and-test` on every push and pull request, `build-and-push` to
  ghcr.io on `main` and on `v*` tags, publishing both `:latest` and the semver
  tag.

### Not yet present

Stated plainly so the gap is not mistaken for an oversight: there is no world, no
creature, no organ, no tick, no energy economy and no evolution. See the README
for the order those arrive in.
