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

# Use Nginx as a web server
FROM nginx:alpine

# Copy the build output to the Nginx web root
COPY --from=builder /app/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
