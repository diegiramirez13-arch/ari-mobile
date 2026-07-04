FROM node:20-slim
ENV NODE_ENV=production
WORKDIR /app
COPY package.json ./
COPY hybrid-service.js ./
COPY server.js ./
EXPOSE 8080
CMD ["npm", "start"]
