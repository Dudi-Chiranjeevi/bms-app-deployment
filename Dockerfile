# Stage 1: Build the React app
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json first for better caching
COPY package.json package-lock.json ./

# Install dependencies using npm ci for a clean install
RUN npm ci --legacy-peer-deps

# Copy the rest of the application
COPY . .

# Fix OpenSSL error for Webpack
ENV NODE_OPTIONS="--openssl-legacy-provider"

# Build the application
RUN npm run build

# Stage 2: Serve the React app using a lightweight server (Serve)
FROM node:18-alpine AS runner

# Set working directory
WORKDIR /app

# Install 'serve' package globally
RUN npm install -g serve

# Copy build output from the builder stage
COPY --from=builder /app/build ./build

# Expose port 3000
EXPOSE 3000

# Start the application using 'serve'
CMD ["serve", "-s", "build", "-l", "3000"]
