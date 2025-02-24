# Use a smaller base image for efficiency
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy only package.json and package-lock.json first to optimize caching
COPY package.json package-lock.json ./

# Install dependencies without unnecessary cache
RUN npm ci --legacy-peer-deps --no-audit --no-fund

# Copy the rest of the application (excluding node_modules due to .dockerignore)
COPY . .

# Build the project
RUN npm run build

# Use a lightweight final image
FROM node:18-alpine

WORKDIR /app

# Copy only necessary built files from builder stage
COPY --from=builder /app/build ./build
COPY --from=builder /app/package.json ./

# Install only production dependencies
RUN npm ci --only=production --no-audit --no-fund

# Install a minimal HTTP server
RUN npm install -g serve

# Expose the necessary port
EXPOSE 3000

# Start the application
CMD ["serve", "-s", "build", "-l", "3000"]
