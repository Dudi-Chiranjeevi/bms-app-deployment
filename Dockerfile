# Use a Node.js builder image for installing dependencies and building the app
FROM node:18 AS builder

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json first for better caching
COPY package.json package-lock.json ./

# Force install a compatible PostCSS version to fix the issue
RUN npm install postcss@8.4.21 postcss-safe-parser@6.0.0 --legacy-peer-deps

# Install dependencies
RUN npm install

# Copy the entire project
COPY . .

# Build the application (modify if you have a build step, e.g., React or TypeScript projects)
RUN npm run build

# Use a lightweight distroless Node.js base image for running the app
FROM gcr.io/distroless/nodejs:18

# Set working directory in the new container
WORKDIR /app

# Copy only necessary files from the builder stage
COPY --from=builder /app /app

# Expose port 3000
EXPOSE 3000

# Set environment variable to prevent OpenSSL errors
ENV NODE_OPTIONS=--openssl-legacy-provider
ENV PORT=3000

# Start the application
CMD ["npm", "start"]

