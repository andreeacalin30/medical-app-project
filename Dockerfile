FROM node:18-alpine

WORKDIR /directus

# Install required packages
RUN apk add --no-cache \
    python3 \
    build-base \
    g++ \
    cairo-dev \
    jpeg-dev \
    pango-dev \
    giflib-dev

# Copy package files
COPY package.json ./
COPY schema.sql ./

# Install dependencies
RUN npm install

# Install Directus globally to ensure it's in PATH
RUN npm install -g directus

# Expose the port
EXPOSE 8055

# Bootstrap and start Directus 
CMD npx directus bootstrap && npx directus start