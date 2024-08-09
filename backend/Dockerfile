# Dockerfile for backend
FROM node:14
WORKDIR ./
COPY app.js ./
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 5000
CMD ["node", "app.js"]

