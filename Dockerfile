FROM node:20-bookworm-slim

# Install dependencies needed by the app
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     ffmpeg \
     imagemagick \
     webp \
     ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install JS deps first to leverage Docker layer cache
COPY package.json ./

# Prefer npm ci when lockfile exists, fallback to npm install
RUN if [ -f package-lock.json ]; then npm ci --omit=dev; else npm install --production; fi \
  && npm install -g pm2 qrcode-terminal

# Copy the rest of the project
COPY . .

ENV NODE_ENV=production \
    PORT=7860

# Match the port used by index.js (default 7860)
EXPOSE 7860

# Use your existing npm start (pm2 attach keeps the process in foreground)
CMD ["npm", "start"]
