FROM node:24.19.0-alpine AS builder

RUN apk add --no-cache git

WORKDIR /app

# Renovate-managed commit SHA of the stable upstream release branch.
# renovate: datasource=git-refs depName=github-stats-extended packageName=https://github.com/stats-organization/github-stats-extended currentValue=release
ARG GSE_REF=84835caea1ffa3c3809b927547b8f69bfd6b80db

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

FROM node:24.19.0-alpine AS runtime
LABEL org.opencontainers.image.source="https://github.com/GeorgesAlkhouri/github-readme-stats-selfhosted" \
  org.opencontainers.image.description="Hardened, reproducible Docker image for stats-organization/github-stats-extended" \
  org.opencontainers.image.licenses="MIT"

RUN addgroup -S app && adduser -S -G app app

WORKDIR /app

COPY --from=builder /prod/backend /app

ENV NODE_ENV=production \
  PORT=9000

EXPOSE 9000

USER app

CMD ["node", "express.js"]
