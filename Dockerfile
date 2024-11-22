# Use a lightweight Node.js image as the base
FROM node:18-alpine AS base

# Set the working directory inside the container
WORKDIR /app

# Install dependencies in a separate layer for caching
COPY package.json package-lock.json ./
RUN npm install

# Copy the rest of the application source code
COPY . .

# Build the Next.js application
FROM base AS builder
RUN npm run build

# Create a production-ready image
FROM node:18-alpine AS production

# Set the environment variable for production
ENV NODE_ENV=production

# Set the working directory inside the container
WORKDIR /app

# Copy only the necessary files from the builder stage
COPY --from=builder /app/package.json /app/package-lock.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules

# Expose the Next.js default port
EXPOSE 3000

# Start the Next.js application
CMD ["npm", "start"]
