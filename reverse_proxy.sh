sudo cd /home/ubuntu
sudo apt update -y
sudo apt install nginx -y

cat > /etc/nginx/sites-available/your_app <<EOL
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://0.0.0.0:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOL

ln -s /etc/nginx/sites-available/your_app /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
cd /etc/nginx/sites-enabled/
sudo rm default
systemctl reload nginx
rails server -b 0.0.0.0
