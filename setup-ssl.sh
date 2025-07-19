#!/bin/bash

# SSL/HTTPS Setup Script for AI Cover Letter Generator
# This script sets up Let's Encrypt SSL certificate and configures HTTPS

echo "Setting up HTTPS with Let's Encrypt SSL certificate..."

# Check if we're running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo"
    exit 1
fi

# Get the domain name or IP address
read -p "Enter your domain name (e.g., example.com) or leave blank to use IP address: " DOMAIN_NAME

if [ -z "$DOMAIN_NAME" ]; then
    # Use the public IP address
    PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
    echo "Using IP address: $PUBLIC_IP"
    DOMAIN_NAME=$PUBLIC_IP
    USE_IP=true
else
    echo "Using domain: $DOMAIN_NAME"
    USE_IP=false
fi

# Install Certbot for Let's Encrypt
echo "Installing Certbot (Let's Encrypt client)..."
apt update
apt install -y snapd
snap install core; snap refresh core
snap install --classic certbot

# Create a symlink for certbot
ln -sf /snap/bin/certbot /usr/bin/certbot

if [ "$USE_IP" = true ]; then
    echo "Note: Let's Encrypt cannot issue certificates for IP addresses."
    echo "Setting up self-signed certificate instead..."
    
    # Create self-signed certificate for IP address
    mkdir -p /etc/ssl/private
    mkdir -p /etc/ssl/certs
    
    # Generate private key
    openssl genrsa -out /etc/ssl/private/ai-cover-letter.key 2048
    
    # Generate self-signed certificate
    openssl req -new -x509 -key /etc/ssl/private/ai-cover-letter.key \
        -out /etc/ssl/certs/ai-cover-letter.crt -days 365 \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=$PUBLIC_IP"
    
    SSL_CERT_PATH="/etc/ssl/certs/ai-cover-letter.crt"
    SSL_KEY_PATH="/etc/ssl/private/ai-cover-letter.key"
    
    echo "Self-signed certificate created."
    echo "WARNING: Browsers will show a security warning for self-signed certificates."
    
else
    echo "Obtaining Let's Encrypt certificate for $DOMAIN_NAME..."
    
    # Stop nginx temporarily
    systemctl stop nginx
    
    # Obtain certificate
    certbot certonly --standalone -d $DOMAIN_NAME --non-interactive --agree-tos \
        --email admin@$DOMAIN_NAME --no-eff-email
    
    if [ $? -eq 0 ]; then
        SSL_CERT_PATH="/etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem"
        SSL_KEY_PATH="/etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem"
        echo "Let's Encrypt certificate obtained successfully!"
    else
        echo "Failed to obtain Let's Encrypt certificate. Setting up self-signed certificate..."
        
        # Fallback to self-signed certificate
        mkdir -p /etc/ssl/private
        mkdir -p /etc/ssl/certs
        
        openssl genrsa -out /etc/ssl/private/ai-cover-letter.key 2048
        openssl req -new -x509 -key /etc/ssl/private/ai-cover-letter.key \
            -out /etc/ssl/certs/ai-cover-letter.crt -days 365 \
            -subj "/C=US/ST=State/L=City/O=Organization/CN=$DOMAIN_NAME"
        
        SSL_CERT_PATH="/etc/ssl/certs/ai-cover-letter.crt"
        SSL_KEY_PATH="/etc/ssl/private/ai-cover-letter.key"
    fi
fi

# Create HTTPS-enabled Nginx configuration
echo "Configuring Nginx for HTTPS..."

cat > /etc/nginx/sites-available/ai-cover-letter-ssl << EOF
# HTTP to HTTPS redirect
server {
    listen 80;
    server_name $DOMAIN_NAME;
    return 301 https://\$server_name\$request_uri;
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name $DOMAIN_NAME;

    # SSL Configuration
    ssl_certificate $SSL_CERT_PATH;
    ssl_certificate_key $SSL_KEY_PATH;
    
    # Modern SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_timeout 1d;
    ssl_session_cache shared:MozTLS:10m;
    ssl_session_tickets off;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=63072000" always;
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";

    # Serve the frontend
    location / {
        root /opt/ai-cover-letter;
        index index.html;
        try_files \$uri \$uri/ =404;
        
        # Security headers for static files
        add_header Cache-Control "public, max-age=31536000" always;
    }

    # Proxy API requests with HTTPS headers
    location /api/scraper/ {
        proxy_pass http://localhost:8000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Forwarded-Ssl on;
    }

    location /api/cover-letter/ {
        proxy_pass http://localhost:8001/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Forwarded-Ssl on;
    }

    location /api/text-extractor/ {
        proxy_pass http://localhost:8002/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Forwarded-Ssl on;
    }

    location /api/ai-generator/ {
        proxy_pass http://localhost:8003/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Forwarded-Ssl on;
    }
}
EOF

# Enable the new SSL configuration
ln -sf /etc/nginx/sites-available/ai-cover-letter-ssl /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/ai-cover-letter

# Test Nginx configuration
nginx -t

if [ $? -eq 0 ]; then
    echo "Nginx configuration is valid"
    
    # Update firewall to allow HTTPS
    echo "Updating firewall rules..."
    ufw allow 443/tcp
    
    # Restart Nginx
    systemctl restart nginx
    
    # Set up automatic certificate renewal (for Let's Encrypt only)
    if [ "$USE_IP" = false ] && [ -f "/etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem" ]; then
        echo "Setting up automatic certificate renewal..."
        echo "0 12 * * * /usr/bin/certbot renew --quiet" | crontab -
    fi
    
    echo ""
    echo "HTTPS setup completed successfully!"
    echo ""
    echo "Your secure application is now available at:"
    echo "https://$DOMAIN_NAME"
    echo ""
    echo "HTTP requests will automatically redirect to HTTPS"
    
    if [ "$USE_IP" = true ]; then
        echo ""
        echo "NOTE: Using self-signed certificate with IP address."
        echo "Browsers will show a security warning. Click 'Advanced' and 'Proceed' to continue."
        echo ""
        echo "For production use, consider:"
        echo "1. Using a domain name instead of IP address"
        echo "2. Getting a proper SSL certificate from Let's Encrypt or a CA"
    fi
    
else
    echo "Nginx configuration test failed. Please check the configuration."
    exit 1
fi