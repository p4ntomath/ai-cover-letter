# EC2 Deployment Checklist for AI Cover Letter Generator

## Pre-Deployment Setup

### 1. EC2 Instance Requirements
- **Instance Type**: t3.medium or larger (minimum 2GB RAM)
- **OS**: Ubuntu 22.04 LTS
- **Storage**: 20GB+ EBS volume
- **Security Group**: Allow ports 22 (SSH), 80 (HTTP), 443 (HTTPS)

### 2. Local Preparation
- [ ] Create `.env` file with your secrets
- [ ] Test all APIs locally
- [ ] Verify GitHub token works
- [ ] Backup your project files

## Deployment Steps

### Step 1: Connect to EC2
```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
```

### Step 2: Upload Project Files
```bash
# From your local machine
scp -i your-key.pem -r * ubuntu@your-ec2-ip:/home/ubuntu/ai-cover-letter/
```

### Step 3: Create .env File on EC2
```bash
# On EC2 instance
cd /home/ubuntu/ai-cover-letter
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

## Access Your Application
- HTTP: `http://your-ec2-ip`
- API Health: `http://your-ec2-ip/api/scraper/health`