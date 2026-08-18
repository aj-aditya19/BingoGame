FROM node::20-alpine
WORKDIR /backend
COPY package*.json ./
RUN npm install
COPY ..
EXPOSE 5000
CMD ["npm", "start"]