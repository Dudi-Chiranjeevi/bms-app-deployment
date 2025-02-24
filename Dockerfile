# Use a Node.js builder image for installing dependencies and building the app
FROM node:18 AS builder

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json first for better caching
COPY package.json package-lock.json ./

# Set environment variable to prevent OpenSSL errors during build
ENV NODE_OPTIONS="--openssl-legacy-provider"

# Force install a compatible PostCSS version to fix the issue
RUN npm install postcss@8.4.21 postcss-safe-parser@6.0.0 --legacy-peer-deps

# Install dependencies using npm ci if package-lock.json is available
RUN npm ci

# Copy the entire project
COPY . . 

# Build the application
RUN npm run build

# Use a lightweight Node.js base image for running the app
FROM node:18-alpine

# Set working directory in the new container
WORKDIR /app

# Copy only the necessary files from the builder stage
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
