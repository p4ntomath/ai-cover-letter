#!/bin/bash

# Quick EC2 Setup Script for Git Clone Deployment
# Run this after cloning the repository on EC2

echo "🚀 Setting up AI Cover Letter Generator from Git..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  Creating .env file from template..."
    cp .env.example .env
    echo "📝 Please edit .env file with your GitHub token:"
    echo "   nano .env"
    echo ""
    echo "🔑 Add your GITHUB_TOKEN to the .env file, then run this script again."
    exit 1
fi

# Verify GitHub token is set
if ! grep -q "ghp_" .env && ! grep -q "github_pat_" .env; then
    echo "❌ GitHub token not found in .env file!"
    echo "📝 Please edit .env and add your GITHUB_TOKEN:"
    echo "   nano .env"
    exit 1
fi

echo "✅ Environment variables configured"

# Run the main deployment script
echo "🔧 Running deployment script..."
chmod +x deploy.sh
./deploy.sh

echo "🎉 Setup complete!"
echo "🌐 Your application should be available at: http://$(curl -s ifconfig.me)"