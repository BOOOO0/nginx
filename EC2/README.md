# EC2

```bash
    server {
        listen       80;
        listen       [::]:80;
        server_name  ${PUBLIC_IP};
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location /api {
            proxy_pass ${PRIVATE_IP}:8080;
            proxy_set_header X-Real_IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $http_host;
            try_files $uri $uri/ /index.html;
        }
    }
```
