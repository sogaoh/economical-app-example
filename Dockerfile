#FROM --platform=linux/arm64 nginx:alpine
FROM --platform=linux/x86_64 nginx:alpine

COPY ./nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

WORKDIR /app

COPY . .

CMD ["nginx", "-g", "daemon off;"]
