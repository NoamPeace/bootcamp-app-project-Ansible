FROM node:14-alpine

#crate dircetory and copy repo
WORKDIR  /bootcamp-app
COPY /bootcamp-app .

#insatlll dependencies
RUN npm install

#expose port
EXPOSE 8080

CMD npm run initdb && npm run dev
