# github-readme-stats-selfhosted

[![CI](https://github.com/GeorgesAlkhouri/github-readme-stats-selfhosted/actions/workflows/ci.yaml/badge.svg)](https://github.com/GeorgesAlkhouri/github-readme-stats-selfhosted/actions/workflows/ci.yaml)
[![CodeQL](https://github.com/GeorgesAlkhouri/github-readme-stats-selfhosted/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/GeorgesAlkhouri/github-readme-stats-selfhosted/actions/workflows/github-code-scanning/codeql)
[![Release](https://img.shields.io/github/v/release/GeorgesAlkhouri/github-readme-stats-selfhosted?sort=semver)](https://github.com/GeorgesAlkhouri/github-readme-stats-selfhosted/releases)
[![License](https://img.shields.io/github/license/GeorgesAlkhouri/github-readme-stats-selfhosted)](./LICENSE)

> Self-hosted Docker image for [anuraghazra/github-readme-stats](https://github.com/anuraghazra/github-readme-stats),  
> so you can serve your own GitHub stats cards without Vercel.

---

## ✨ What this repo gives you

Self-hosted build of the original github-readme-stats project, packaged as a multi-arch Docker image (amd64/arm64) and continuously synced with upstream main. Images are automatically published to Docker Hub and GHCR for easy deployment on your own infra (Docker, Podman, Kubernetes, etc.).

> Note: Image versions here are **independent of upstream tags**. Upstream doesn’t provide up-to-date releases, so this repo maintains its own semantic versions for published images. We use a semantic-style versioning scheme of `1.X.0`. Minor (`X`) increases track upstream changes; the major version only bumps if something unexpected and breaking happens.

If you just want the public service, use the original project.  
This repo is for people who like to own their infra. 😈
