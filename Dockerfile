FROM node:18 AS builder

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm install --only=production && npm cache clean --force

COPY . .

RUN npm run build

FROM node:18-slim AS runner

WORKDIR /app

COPY --from=builder /app/package.json /app/package-lock.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/build ./build

# Install `serve` for serving static files
RUN npm install -g serve

# Expose port 3000
EXPOSE 3000

# Set environment variables
ENV NODE_OPTIONS=--openssl-legacy-provider
ENV PORT=3000

# Start the application
CMD ["serve", "-s", "build", "-l", "3000"]
