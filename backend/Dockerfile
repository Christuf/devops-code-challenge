FROM node:16

WORKDIR /home/app
COPY package*.json .

RUN npm i
RUN npm i pm2 -g

COPY . /home/app/

EXPOSE 8080

CMD [ "pm2-runtime", "index.js" ]
