# EC2 Deployment Checklist for AI Cover Letter Generator

## Pre-Deployment Setup

### 1. EC2 Instance Requirements
- **Instance Type**: t3.medium or larger (minimum 2GB RAM)
- **OS**: Ubuntu 22.04 LTS
- **Storage**: 20GB+ EBS volume
- **Security Group**: Allow ports 22 (SSH), 80 (HTTP), 443 (HTTPS)

### 2. Local Preparation
- [ ] Push your project to GitHub repository
- [ ] Create `.env.example` file with template variables
- [ ] Test all APIs locally
- [ ] Verify GitHub token works
- [ ] Ensure all secrets are in `.env` (not committed to GitHub)

## Deployment Steps

### Step 1: Connect to EC2
```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
```

### Step 2: Clone Project from GitHub
```bash
# On EC2 instance
cd /home/ubuntu
git clone https://github.com/yourusername/your-repo-name.git ai-cover-letter
cd ai-cover-letter
```

### Step 3: Create .env File on EC2
```bash
# Copy from example and edit with your secrets
cp .env.example .env
nano .env
```

### Step 4: Run Deployment Script
```bash
chmod +x deploy.sh
./deploy.sh
```

### Step 5: Verify Services
```bash
sudo systemctl status job-scraper
sudo systemctl status cover-letter  
sudo systemctl status text-extractor
sudo systemctl status ai-generator
sudo systemctl status nginx
```

## Post-Deployment

### Updates and Redeployment
```bash
# To update your application
cd /opt/ai-cover-letter
git pull origin main
source venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart job-scraper cover-letter text-extractor ai-generator
```

### Service Management Commands
- Check logs: `sudo journalctl -u service-name -f`
- Restart service: `sudo systemctl restart service-name`
- Check all services: `sudo systemctl status nginx job-scraper cover-letter text-extractor ai-generator`

### Troubleshooting
- Nginx logs: `/var/log/nginx/error.log`
- Service logs: `sudo journalctl -u service-name`
- Port check: `sudo netstat -tulpn | grep :80`

### Security Notes
- .env file permissions: `chmod 600 .env`
- Never commit .env to git
- Use IAM roles for production secrets
- Enable HTTPS with Let's Encrypt (optional)

## HTTPS/SSL Setup (Optional but Recommended)

To secure your application with HTTPS and resolve browser security warnings:

### Option 1: Automatic SSL Setup (Recommended)
```bash
# Upload and run the SSL setup script
scp -i your-key.pem setup-ssl.sh ubuntu@your-ec2-ip:/home/ubuntu/
ssh -i your-key.pem ubuntu@your-ec2-ip
chmod +x setup-ssl.sh
sudo ./setup-ssl.sh
```

The script will:
- Install Let's Encrypt (Certbot) for free SSL certificates
- Generate SSL certificate (Let's Encrypt for domains, self-signed for IP addresses)
- Configure Nginx for HTTPS with security headers
- Set up automatic HTTP to HTTPS redirect
- Configure automatic certificate renewal

### Option 2: Manual Domain Setup
If you have a domain name pointing to your EC2 instance:

1. **Point your domain to EC2**:
   - Add an A record in your DNS settings pointing to your EC2 public IP
   - Wait for DNS propagation (5-30 minutes)

2. **Run SSL setup with domain**:
   ```bash
   sudo ./setup-ssl.sh
   # Enter your domain name when prompted (e.g., myapp.example.com)
   ```

3. **Access your secure site**:
   ```
   https://yourdomain.com
   ```

### Option 3: IP Address with Self-Signed Certificate
For IP-based access (current setup):

1. **Run SSL setup without domain**:
   ```bash
   sudo ./setup-ssl.sh
   # Press Enter when prompted for domain (uses IP address)
   ```

2. **Access with browser warning**:
   - Visit: `https://13.61.22.198`
   - Click "Advanced" then "Proceed to 13.61.22.198 (unsafe)"
   - Browser will remember your choice

### Security Features Included:
- **TLS 1.2/1.3 encryption**
- **HTTP to HTTPS redirect**
- **Security headers**: HSTS, X-Frame-Options, X-Content-Type-Options
- **Automatic certificate renewal** (Let's Encrypt only)
- **Modern SSL ciphers**

### Verification:
After setup, test your secure site:
```bash
# Test HTTPS
curl -I https://your-domain-or-ip

# Test HTTP redirect
curl -I http://your-domain-or-ip
```

You should see a 301 redirect from HTTP to HTTPS.

## Access Your Application
- **Secure (HTTPS)**: `https://13.61.22.198` or `https://yourdomain.com`
- **API Health**: `https://13.61.22.198/api/scraper/health`