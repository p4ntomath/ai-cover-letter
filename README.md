# AI Cover Letter Generator 🤖📄

A powerful AI-driven application that automatically generates personalized cover letters by analyzing your resume and job descriptions using GitHub's AI models.

## Features ✨

- **AI-Powered Analysis**: Uses GitHub's GPT-4 model to analyze resumes and job descriptions
- **LinkedIn Job Scraping**: Automatically extracts job descriptions from LinkedIn URLs
- **Multiple File Formats**: Supports PDF and DOCX resume uploads
- **Professional Output**: Generates properly formatted DOCX cover letters
- **Real-time Processing**: Live status updates and progress tracking
- **Multi-Job Support**: Generate multiple cover letters while preserving your resume data

## Architecture 🏗️

The application consists of 4 microservices:

1. **Job Scraper API** (Port 8000) - LinkedIn job description extraction
2. **Cover Letter API** (Port 8001) - DOCX file generation
3. **Text Extractor API** (Port 8002) - PDF/DOCX text extraction
4. **AI Generator API** (Port 8003) - AI analysis and content generation

## Prerequisites 📋

- Python 3.11+
- GitHub Personal Access Token with GitHub Models access
- Ubuntu 22.04 LTS (for EC2 deployment)

## Local Development 🚀

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/ai-cover-letter-generator.git
   cd ai-cover-letter-generator
   ```

2. **Create virtual environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your GitHub token
   ```

5. **Start all services:**
   ```bash
   # Terminal 1
   python job_scraper_api.py
   
   # Terminal 2  
   python model.py
   
   # Terminal 3
   python text_extractor_api.py
   
   # Terminal 4
   python ai_cover_letter_api.py
   ```

6. **Open the application:**
   ```bash
   # Open index.html in your browser or serve it locally
   python -m http.server 3000
   ```

## EC2 Deployment 🌐

### Quick Deploy
```bash
# On your EC2 instance
git clone https://github.com/yourusername/ai-cover-letter-generator.git
cd ai-cover-letter-generator

# Create .env file with your secrets
nano .env

# Run deployment script
chmod +x deploy.sh
./deploy.sh
```

### Manual Setup
See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for detailed instructions.

## Environment Variables 🔐

Create a `.env` file with the following variables:

```env
GITHUB_TOKEN=your_github_token_here
HOST=0.0.0.0
PORT_JOB_SCRAPER=8000
PORT_COVER_LETTER=8001
PORT_TEXT_EXTRACTOR=8002
PORT_AI_GENERATOR=8003
```

## API Endpoints 📡

### Job Scraper API (Port 8000)
- `POST /scrape` - Extract job description from LinkedIn URL
- `GET /health` - Health check

### Cover Letter API (Port 8001)  
- `POST /generate` - Generate DOCX cover letter
- `GET /health` - Health check

### Text Extractor API (Port 8002)
- `POST /extract-text-only` - Extract text from PDF/DOCX
- `GET /health` - Health check

### AI Generator API (Port 8003)
- `POST /analyze-documents` - AI analysis of resume and job description
- `POST /generate-ai-cover-letter` - Complete cover letter generation
- `GET /health` - Health check

## Usage 📖

1. **Upload Resume**: Select your PDF or DOCX resume file
2. **Add Job Description**: Either paste job description text or provide LinkedIn job URL
3. **Generate Cover Letter**: Click generate to create your personalized cover letter
4. **Download**: Download the professionally formatted DOCX file

## Security 🔒

- Environment variables are never committed to the repository
- Secrets are loaded securely via systemd in production
- All services run as non-root users
- Firewall configured for secure access

## Contributing 🤝

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License 📝

This project is licensed under the MIT License - see the LICENSE file for details.

## Support 💬

If you encounter any issues or have questions, please open an issue on GitHub.

---

**Made with ❤️ and AI**