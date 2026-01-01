FROM nginx:alpine

RUN apk update && apk upgrade

RUN rm /usr/share/nginx/html/index.html

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
