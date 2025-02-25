# Using base image
FROM node:18 AS builder

# Setting work directory 
WORKDIR /app

# Copying files to the container 
COPY package.json package-lock.json ./

# Set OpenSSL legacy provider before running npm install and build
ENV NODE_OPTIONS=--openssl-legacy-provider

# Installs only the production dependencies (not dev dependencies).
RUN npm install --only=production && npm cache clean --force

# Copy the Entire Application to the /app directory
COPY . .

# It runs build script
RUN npm run build

# It is using the base image as Slim to keep final image light weight 
FROM node:18-slim AS runner

# Sets working directory again
WORKDIR /app

# Copies the required files from builder stage
COPY --from=builder /app/package.json /app/package-lock.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/build ./build

# Install `serve` for serving static files
RUN npm install -g serve

# Expose port 3000
EXPOSE 3000

# Start the application
CMD ["serve", "-s", "build", "-l", "3000"]
