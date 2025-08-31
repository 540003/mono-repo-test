# ---------------- Base builder ----------------
    FROM node:20.19.0-alpine AS builder  

    # Install pnpm globally
    RUN npm install -g pnpm
    
    WORKDIR /app
    
    # Copy monorepo config first (better caching)
    COPY pnpm-workspace.yaml pnpm-lock.yaml package.json ./
    
    # Copy package.json files for all workspaces
    COPY apps/frontend/package.json apps/frontend/
    COPY apps/backend/package.json apps/backend/
    COPY packages/shared/package.json packages/shared/
    
    # Install all dependencies (dev included for build)
    RUN pnpm install --frozen-lockfile
    
    # Copy source code
    COPY . .
    
    # Build frontend
    RUN pnpm --filter frontend run build
    
    # Build backend (if needed, e.g. TS -> JS)
    RUN pnpm --filter backend run build
    
    
    # ---------------- Backend runtime ----------------
    FROM node:20.19.0-alpine AS backend
    
    WORKDIR /app
    
    # Install pnpm globally
    RUN npm install -g pnpm
    
    # Copy from builder
    COPY --from=builder /app/node_modules ./node_modules
    COPY --from=builder /app/apps/backend ./apps/backend
    COPY --from=builder /app/packages/shared ./packages/shared
    COPY --from=builder /app/apps/frontend/dist ./apps/frontend/dist
    
    WORKDIR /app/apps/backend
    
    # Only install prod deps for backend
    RUN pnpm install --prod --frozen-lockfile
    
    EXPOSE 3000
    CMD ["pnpm", "start"]
    