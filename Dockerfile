FROM nginx:alpine

COPY ./nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

WORKDIR /app

COPY . .

CMD ["nginx", "-g", "daemon off;"]
