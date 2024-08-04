# Dockerfile for backend
FROM node:14
WORKDIR ./
COPY app.js ./
COPY package*.json ./
RUN npm install
CMD ["node", "app.js"]

