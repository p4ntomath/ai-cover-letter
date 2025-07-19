#!/bin/bash

# EC2 Deployment Script for AI Cover Letter Generator
# Run this script on your EC2 instance after cloning from GitHub

echo "🚀 Starting AI Cover Letter Generator Deployment..."

# Check if we're in the right directory
if [ ! -f "requirements.txt" ]; then
    echo "❌ Error: requirements.txt not found. Make sure you're in the project directory."
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "❌ Error: .env file not found! Please create it from .env.example"
    echo "Run: cp .env.example .env && nano .env"
    exit 1
fi

# Update system packages
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Python 3.11 and pip
echo "🐍 Installing Python 3.11..."
sudo apt install -y python3.11 python3.11-venv python3.11-dev python3-pip git

# Install system dependencies for PDF processing
echo "📄 Installing system dependencies..."
sudo apt install -y build-essential libpoppler-cpp-dev pkg-config python3-dev

# Create application directory and copy files
echo "📁 Setting up application directory..."
sudo mkdir -p /opt/ai-cover-letter
sudo chown $USER:$USER /opt/ai-cover-letter

# Copy all files to deployment directory
echo "📋 Copying project files..."
cp -r * /opt/ai-cover-letter/
cd /opt/ai-cover-letter

# Set proper permissions for .env
chmod 600 .env

# Create Python virtual environment
echo "🔧 Creating virtual environment..."
python3.11 -m venv venv
source venv/bin/activate

# Install Python dependencies
echo "📋 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Create systemd service files
echo "⚙️  Creating systemd services..."

# Create service for Job Scraper API
sudo tee /etc/systemd/system/job-scraper.service > /dev/null <<EOF
[Unit]
Description=Job Scraper API
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=/opt/ai-cover-letter
Environment=PATH=/opt/ai-cover-letter/venv/bin
EnvironmentFile=/opt/ai-cover-letter/.env
ExecStart=/opt/ai-cover-letter/venv/bin/python job_scraper_api.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Create service for Cover Letter API
sudo tee /etc/systemd/system/cover-letter.service > /dev/null <<EOF
[Unit]
Description=Cover Letter API
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=/opt/ai-cover-letter
Environment=PATH=/opt/ai-cover-letter/venv/bin
EnvironmentFile=/opt/ai-cover-letter/.env
ExecStart=/opt/ai-cover-letter/venv/bin/python model.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Create service for Text Extractor API
sudo tee /etc/systemd/system/text-extractor.service > /dev/null <<EOF
[Unit]
Description=Text Extractor API
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=/opt/ai-cover-letter
Environment=PATH=/opt/ai-cover-letter/venv/bin
EnvironmentFile=/opt/ai-cover-letter/.env
ExecStart=/opt/ai-cover-letter/venv/bin/python text_extractor_api.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Create service for AI Generator API
sudo tee /etc/systemd/system/ai-generator.service > /dev/null <<EOF
[Unit]
Description=AI Generator API
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=/opt/ai-cover-letter
Environment=PATH=/opt/ai-cover-letter/venv/bin
EnvironmentFile=/opt/ai-cover-letter/.env
ExecStart=/opt/ai-cover-letter/venv/bin/python ai_cover_letter_api.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Install and configure Nginx
echo "🌐 Installing and configuring Nginx..."
sudo apt install -y nginx

# Get the current server IP for nginx config
SERVER_IP=$(curl -s http://checkip.amazonaws.com)

# Create Nginx configuration
sudo tee /etc/nginx/sites-available/ai-cover-letter > /dev/null <<EOF
server {
    listen 80;
    server_name ${SERVER_IP};  # Uses your EC2 public IP

    # Serve the frontend
    location / {
        root /opt/ai-cover-letter;
        index index.html;
        try_files \$uri \$uri/ =404;
    }

    # Proxy API requests
    location /api/scraper/ {
        proxy_pass http://localhost:8000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /api/cover-letter/ {
        proxy_pass http://localhost:8001/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /api/text-extractor/ {
        proxy_pass http://localhost:8002/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /api/ai-generator/ {
        proxy_pass http://localhost:8003/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/ai-cover-letter /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t

# Reload systemd and start services
echo "🔄 Starting services..."
sudo systemctl daemon-reload
sudo systemctl enable job-scraper cover-letter text-extractor ai-generator nginx
sudo systemctl start job-scraper cover-letter text-extractor ai-generator nginx

# Configure firewall
echo "🔥 Configuring firewall..."
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw --force enable

echo "✅ Deployment complete!"
echo "🌐 Your application is available at: http://${SERVER_IP}"
echo "📊 Check service status with: sudo systemctl status [service-name]"
echo ""
echo "📋 Quick commands:"
echo "  Status: sudo systemctl status nginx job-scraper cover-letter text-extractor ai-generator"
echo "  Logs: sudo journalctl -u [service-name] -f"
echo "  Restart: sudo systemctl restart [service-name]"