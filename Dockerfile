FROM node:24.22.3-alpine@sha256:116b800c3754b440ee0aa3ed2f20f5bf3d99a554bfd9adeea09ea8017f6e85f5 AS builder

RUN apk add --no-cache git

WORKDIR /app

# Renovate-managed commit SHA of the stable upstream release branch.
# Renovate only exposes upstream commits after a seven-day waiting period.
# renovate: datasource=custom.github-stats-extended-aged depName=github-stats-extended packageName=stats-organization/github-stats-extended currentValue=0
ARG GSE_REF=fe0684b3d454ee6b558b60d7f3d90f1027a8c0f8

# 1) Clone upstream repo
RUN git clone https://github.com/stats-organization/github-stats-extended.git . \
  && git checkout "${GSE_REF}"

# 2) Install the pinned pnpm workspace and build the shared core package.
RUN corepack enable \
  && pnpm install --frozen-lockfile --ignore-scripts \
  && pnpm run build:packages

# 3) Promote upstream's exact Express version to a runtime dependency, then
# deploy only the backend and its production dependencies.
RUN node -e 'const fs = require("fs"); const path = "apps/backend/package.json"; const pkg = JSON.parse(fs.readFileSync(path)); const version = pkg.dependencies?.express ?? pkg.devDependencies?.express; if (!version) throw new Error("Upstream no longer declares express"); pkg.dependencies = { ...pkg.dependencies, express: version }; if (pkg.devDependencies) delete pkg.devDependencies.express; fs.writeFileSync(path, JSON.stringify(pkg, null, 2) + "\n");' \
  && pnpm --ignore-scripts --filter @stats-organization/github-readme-stats-backend --prod deploy --legacy /prod/backend

FROM node:24.22.3-alpine@sha256:116b800c3754b440ee0aa3ed2f20f5bf3d99a554bfd9adeea09ea8017f6e85f5 AS runtime
LABEL org.opencontainers.image.source="https://github.com/GeorgesAlkhouri/github-readme-stats-selfhosted" \
  org.opencontainers.image.description="Hardened, reproducible Docker image for stats-organization/github-stats-extended" \
  org.opencontainers.image.licenses="MIT"

# Pull Alpine security fixes that are newer than the pinned base image, then
# drop the bundled package managers. The container only runs `node express.js`,
# so npm, corepack and yarn are unused attack surface.
RUN apk upgrade --no-cache \
  && rm -rf \
    /usr/local/lib/node_modules/npm \
    /usr/local/lib/node_modules/corepack \
    /usr/local/bin/npm \
    /usr/local/bin/npx \
    /usr/local/bin/corepack \
    /opt/yarn-v* \
    /usr/local/bin/yarn \
    /usr/local/bin/yarnpkg

RUN addgroup -S app && adduser -S -G app app

WORKDIR /app

COPY --from=builder /prod/backend /app

ENV NODE_ENV=production \
  PORT=9000

EXPOSE 9000

USER app

CMD ["node", "express.js"]
