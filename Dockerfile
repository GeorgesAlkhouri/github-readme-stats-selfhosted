FROM node:22.21.0-alpine AS builder

RUN apk add --no-cache git

WORKDIR /app

# Renovate-managed commit SHA of upstream.
# Renovate will update GRS_REF whenever upstream master changes.
# renovate: datasource=git-refs depName=github-readme-stats packageName=https://github.com/anuraghazra/github-readme-stats currentValue=master
ARG GRS_REF=adf2a65dcc862006bc1f80e25580c8f5a6ca8504

# 1) Clone upstream repo
RUN git clone https://github.com/anuraghazra/github-readme-stats.git . \
  && git checkout "${GRS_REF}"

# 2) Install dependencies as upstream defines them.
RUN if [ -f package-lock.json ]; then \
  npm ci --ignore-scripts --no-audit; \
  else \
  npm install --ignore-scripts --no-audit; \
  fi

FROM node:22.21.1-alpine AS runtime
LABEL org.opencontainers.image.source="https://github.com/<you>/github-readme-stats-image" \
  org.opencontainers.image.description="Hardened, reproducible Docker image for anuraghazra/github-readme-stats" \
  org.opencontainers.image.licenses="MIT"

RUN addgroup -S app && adduser -S -G app app

WORKDIR /app

COPY --from=builder /app /app

ENV NODE_ENV=production \
  PORT=9000

EXPOSE 9000

USER app

CMD ["node", "express.js"]
