FROM python:3.7.1-alpine3.8

RUN apk update && apk --no-cache add nginx

RUN touch /var/log/nginx/jack_bunny.log

COPY code ./
WORKDIR /jack_bunny

RUN pip install --upgrade pip==20.0.2 && pip install --no-cache-dir -r requirements.txt

EXPOSE 80

COPY jack_bunny.nginx /etc/nginx/conf.d/default.conf
ENTRYPOINT gunicorn jack_bunny:app -b 0.0.0.0:7016 -p /var/run/jack_bunny.pid -D && nginx -c /etc/nginx/nginx.conf -g "pid /var/run/nginx.pid; daemon off;"
