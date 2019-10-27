FROM nginx:alpine

COPY ./nginx.conf /etc/nginx/nginx.conf
RUN rm -r /etc/nginx/conf.d
ADD conf.d /etc/nginx/conf.d

ENTRYPOINT ["nginx", "-g", "daemon off;"]
