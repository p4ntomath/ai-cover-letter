# AI Cover Letter Generator

An intelligent web application that generates personalized cover letters using AI analysis of resumes and job descriptions. The system includes LinkedIn job scraping, document text extraction, and AI-powered content generation.

- **Deployed Site** : [ai-cover-letter-8jxb.onrender.com](https://ai-cover-letter-8jxb.onrender.com/)

## Features

-  **AI-Powered Analysis**: Uses GitHub Models AI to analyze resumes and job descriptions
-  **Document Processing**: Extracts text from PDF and DOCX files
-  **LinkedIn Integration**: Scrapes job descriptions directly from LinkedIn job postings
-  **Professional Output**: Generates properly formatted DOCX cover letters
-  **Web Interface**: Clean, responsive web UI for easy interaction
-  **Multi-API Architecture**: Modular FastAPI microservices

## Tech Stack

- **Backend**: FastAPI, Python 3.8+
- **AI**: GitHub Models (GPT-4o)
- **Document Processing**: pdfplumber, python-docx
- **Web Scraping**: BeautifulSoup4, requests
- **Frontend**: HTML, JavaScript, Tailwind CSS
- **Environment**: python-dotenv

## Prerequisites

- Python 3.8 or higher
- GitHub account with access to GitHub Models
- Git (optional, for cloning)

## Quick Start

### Install Command
```bash
# Clone the repository
git clone https://github.com/p4ntomath/ai-cover-letter.git
cd ai-cover-letter

# Install dependencies
pip install -r requirements.txt
```

### Start Command
```bash
# Development mode
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Production mode
uvicorn main:app --host 0.0.0.0 --port 8000
```

### Output Directory
- **Generated Cover Letters**: Downloaded directly to user's browser downloads folder
- **Static Assets**: Served from `./static/` directory
- **API Endpoints**: All accessible at runtime (no build artifacts)
- **Temporary Files**: Processed in memory (no persistent output directory)

## Installation & Setup

### 1. Clone or Download the Project

```bash
git clone https://github.com/p4ntomath/ai-cover-letter.git
cd ai-cover-letter
```

Or download and extract the ZIP file to your desired directory.

### 2. Create Virtual Environment (Recommended)

```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

If you encounter any issues, try upgrading pip first:
```bash
python -m pip install --upgrade pip
pip install -r requirements.txt
```

### 4. Environment Configuration

1. Create your environment file:
   ```bash
   # On Windows:
   copy .env.example .env
   # On macOS/Linux:
   cp .env.example .env
   ```

2. Edit the `.env` file and add your GitHub token:
   ```
   GITHUB_TOKEN=your_actual_github_token_here
   ```

#### Getting a GitHub Token:

1. Go to [GitHub Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Give it a descriptive name (e.g., "AI Cover Letter Generator")
4. Select appropriate scopes (for GitHub Models access)
5. Copy the generated token to your `.env` file

### 5. Verify Installation

Test that all dependencies are properly installed:

```bash
python -c "import fastapi, uvicorn, requests, beautifulsoup4, pdfplumber, docx; print('All dependencies installed successfully!')"
```

## Deployment

### Local Development Deployment

```bash
# Quick start for development
git clone https://github.com/p4ntomath/ai-cover-letter.git
cd ai-cover-letter
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Production Deployment

#### Build Commands
```bash
# No build step required - FastAPI application runs directly
# Optional: Create optimized requirements for production
pip freeze > requirements-prod.txt
```

#### Install Commands
```bash
# Production installation
pip install -r requirements.txt --no-cache-dir

# Or with specific versions for stability
pip install -r requirements.txt --no-deps
```

#### Start Commands
```bash
# Basic production start
uvicorn main:app --host 0.0.0.0 --port 8000

# Production with workers (recommended)
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4

# With specific configurations
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4 --access-log --log-level info
```

### Platform-Specific Deployment

#### Render.com (Current Deployment)
```bash
# Build Command: (leave empty or use)
pip install -r requirements.txt

# Start Command:
uvicorn main:app --host 0.0.0.0 --port $PORT
```

#### Heroku
```bash
# Create Procfile with:
web: uvicorn main:app --host 0.0.0.0 --port $PORT

# Build Command: (automatic via requirements.txt)
# Start Command: (automatic via Procfile)
```

#### Railway
```bash
# Build Command:
pip install -r requirements.txt

# Start Command:
uvicorn main:app --host 0.0.0.0 --port $PORT
```

#### Docker Deployment
```bash
# Create Dockerfile (example):
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

# Build and run:
docker build -t ai-cover-letter .
docker run -p 8000:8000 ai-cover-letter
```

### Output Directory Structure

```
Project Root/
├── main.py                    # Main application entry point
├── *_api.py                   # API modules (no build artifacts)
├── requirements.txt           # Dependencies list
├── .env                      # Environment variables (not in repo)
├── static/                   # Static files served directly
│   └── index.html           # Frontend interface
├── __pycache__/             # Python bytecode (auto-generated)
│   └── *.pyc               # Compiled Python files
└── [Generated Files]        # Runtime generated files:
    ├── cover_letter_*.docx  # Downloaded by users
    └── temp_uploads/        # Temporary file processing (if implemented)
```

**Note**: This is a serverless application - no build artifacts are created. All files are served directly from source.

## Running the Application

### Development Mode

Start the application in development mode with auto-reload:

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Production Mode

For production deployment:

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

### Using Different Ports

If port 8000 is busy, use a different port:

```bash
uvicorn main:app --reload --port 8080
```

### Environment Variables for Deployment

```bash
# Required
GITHUB_TOKEN=your_github_token_here

# Optional deployment variables
PORT=8000                    # Server port (auto-set by most platforms)
WORKERS=4                    # Number of worker processes
LOG_LEVEL=info              # Logging level
HOST=0.0.0.0                # Bind address
```

## Accessing the Application

Once the server is running, you can access:

- **Web Interface**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **Alternative API Docs**: http://localhost:8000/redoc
- **Health Check**: http://localhost:8000/api/*/health

## API Endpoints

The application consists of four main APIs:

### 1. Job Scraper API (`/api/scraper`)
- `POST /api/scraper/scrape` - Scrape LinkedIn job descriptions
- `GET /api/scraper/health` - Health check

### 2. Cover Letter API (`/api/cover`)
- `POST /api/cover/generate` - Generate DOCX cover letter from structured data
- `GET /api/cover/health` - Health check

### 3. Text Extractor API (`/api/extract`)
- `POST /api/extract/extract` - Extract text from PDF/DOCX files
- `POST /api/extract/extract-detailed` - Detailed extraction with metadata
- `POST /api/extract/extract-text-only` - Simple text extraction
- `GET /api/extract/health` - Health check

### 4. AI Cover Letter API (`/api/ai`)
- `POST /api/ai/analyze-documents` - AI analysis of resume and job description
- `POST /api/ai/generate-ai-cover-letter` - End-to-end AI cover letter generation
- `GET /api/ai/health` - Health check

## Usage Guide

### Web Interface

1. **Upload Resume**: Select your resume file (PDF or DOCX)
2. **Add Job Description**: Either:
   - Paste a LinkedIn job URL to auto-scrape
   - Manually paste the job description text
3. **Generate Cover Letter**: Click generate to create your personalized cover letter
4. **Download**: Save the generated DOCX file

### API Usage Examples

#### Scrape LinkedIn Job:
```bash
curl -X POST "http://localhost:8000/api/scraper/scrape" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://www.linkedin.com/jobs/view/123456789"}'
```

#### Extract Text from File:
```bash
curl -X POST "http://localhost:8000/api/extract/extract-text-only" \
  -F "file=@resume.pdf"
```

## Project Structure

```
Python/
├── main.py                    # Main FastAPI application
├── job_scraper_api.py        # LinkedIn job scraping API
├── cover_letter_api.py       # Cover letter generation API
├── text_extractor_api.py     # Document text extraction API
├── ai_cover_letter_api.py    # AI-powered cover letter API
├── requirements.txt          # Python dependencies
├── .env.example             # Environment variables template
├── .env                     # Environment variables (create this)
├── .gitignore              # Git ignore rules
├── README.md               # This file
└── static/
    └── index.html          # Web interface
```

## Troubleshooting

### Common Issues

1. **Port Already in Use**:
   ```bash
   # Use a different port
   uvicorn main:app --reload --port 8080
   ```

2. **Missing Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **GitHub Token Issues**:
   - Verify your token in the `.env` file
   - Check token permissions and expiration
   - Test with: `curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user`

4. **File Upload Issues**:
   - Ensure files are PDF or DOCX format
   - Check file size limits
   - Verify file is not corrupted

5. **LinkedIn Scraping Issues**:
   - LinkedIn may block requests; try different URLs
   - Ensure the URL is a valid LinkedIn job posting
   - Use manual text input as an alternative

### Debug Mode

Run with debug logging:

```bash
uvicorn main:app --reload --log-level debug
```

### Health Checks

Verify all services are running:

```bash
curl http://localhost:8000/api/scraper/health
curl http://localhost:8000/api/cover/health
curl http://localhost:8000/api/extract/health
curl http://localhost:8000/api/ai/health
```

## Development

### Build and Development Workflow

```bash
# 1. Clone and setup
git clone https://github.com/p4ntomath/ai-cover-letter.git
cd ai-cover-letter

# 2. Install dependencies
pip install -r requirements.txt

# 3. Set up environment
cp .env.example .env
# Edit .env with your GitHub token

# 4. Run in development mode
uvicorn main:app --reload

# 5. Test the application
curl http://localhost:8000/api/ai/health
```

### Adding New Features

1. Create new API modules following the existing pattern
2. Import and mount in `main.py`
3. Update the web interface in `static/index.html`
4. Add new dependencies to `requirements.txt`
5. Test locally before deploying

### Testing

Test individual APIs:

```bash
# Test job scraper
python -c "import job_scraper_api; print('Job scraper API loaded successfully')"

# Test text extractor
python -c "import text_extractor_api; print('Text extractor API loaded successfully')"

# Test AI generator
python -c "import ai_cover_letter_api; print('AI cover letter API loaded successfully')"
```

## Security Notes

- Keep your `.env` file secure and never commit it to version control
- The GitHub token should have minimal required permissions
- Consider implementing rate limiting for production use
- Validate all file uploads and user inputs

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is for educational and personal use. Please respect LinkedIn's terms of service when scraping job postings.

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Review the API documentation at `/docs`
3. Check server logs for error messages
4. Ensure all dependencies are properly installed

---

**Note**: This application requires a valid GitHub token for AI functionality. The scraping feature should be used responsibly and in accordance with LinkedIn's terms of service.