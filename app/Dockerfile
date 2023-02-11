FROM node:8.11-alpine

WORKDIR /usr/src/app

ARG NODE_ENV
ENV NODE_ENV $NODE_ENV
ENV PORT 5000

COPY package.json /usr/src/app/

RUN npm install

COPY app.js /usr/src/app/

EXPOSE $PORT

CMD [ "npm", "start" ]
