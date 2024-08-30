FROM node:14
WORKDIR /usr/src/app
COPY app.js ./
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 5000
CMD ["node", "app.js"]

