# Use a lightweight Node.js Alpine image for building
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json first for better caching
COPY package.json package-lock.json ./

# Install dependencies using npm ci for a clean install
RUN npm ci --legacy-peer-deps \
    && npm install postcss@8.4.21 postcss-safe-parser@6.0.0 --legacy-peer-deps

# Copy the entire project
COPY . .

# Fix OpenSSL error for Webpack
ENV NODE_OPTIONS="--openssl-legacy-provider"

# Build the application
RUN npm run build

# Use a minimal runtime image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy only necessary files from builder stage
COPY --from=builder /app/build /app/build
COPY --from=builder /app/package.json /app/
COPY --from=builder /app/node_modules /app/node_modules

# Expose port 3000
EXPOSE 3000

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Start the application
CMD ["npm", "start"]
