worker_processes 1;
pid /tmp/nginx.pid;
error_log /dev/stdout warn;

events {
    worker_connections 64;
}

http {
    access_log off;
    client_body_temp_path /tmp/client_body;
    proxy_temp_path /tmp/proxy;
    fastcgi_temp_path /tmp/fastcgi;
    uwsgi_temp_path /tmp/uwsgi;
    scgi_temp_path /tmp/scgi;

    server {
        listen 8099;
        # Только Ingress-шлюз Supervisor.
        allow 172.30.32.2;
        deny all;

        proxy_http_version 1.1;
        proxy_set_header X-Api-Key "@KEY@";
        proxy_set_header Authorization "";
        proxy_set_header Cookie "";
        proxy_set_header Connection "";
        proxy_connect_timeout 5s;

        # Страница панели: параметры вида из настроек аддона.
        location = / {
            proxy_pass @UPSTREAM@/?@PAGE_ARGS@;
        }

        # Поток событий (SSE): без буферизации и с долгим ожиданием.
        location = /api/events {
            proxy_pass @UPSTREAM@;
            proxy_buffering off;
            proxy_cache off;
            proxy_read_timeout 1h;
            proxy_send_timeout 1h;
        }

        location / {
            proxy_pass @UPSTREAM@;
            proxy_read_timeout 30s;
        }
    }
}
