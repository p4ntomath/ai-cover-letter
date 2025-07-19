from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, HttpUrl
import requests
from bs4 import BeautifulSoup
import re
import time
from typing import Optional
import uvicorn

# Initialize FastAPI app
app = FastAPI(
    title="LinkedIn Job Scraper API",
    description="API to scrape job descriptions from LinkedIn job postings",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# Request model
class JobScrapingRequest(BaseModel):
    url: HttpUrl
    
# Response model
class JobScrapingResponse(BaseModel):
    success: bool
    job_description: Optional[str] = None
    error_message: Optional[str] = None
    url: str
    word_count: Optional[int] = None

def scrape_linkedin_job(url: str) -> tuple[bool, str, str]:
    """
    Scrapes text from a LinkedIn job posting
    Returns: (success, job_description, error_message)
    """
    
    # Enhanced headers to better mimic a real browser
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept-Encoding': 'gzip, deflate, br',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
        'Sec-Fetch-Dest': 'document',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-Site': 'none',
        'Sec-Fetch-User': '?1',
        'Cache-Control': 'max-age=0'
    }
    
    session = requests.Session()
    session.headers.update(headers)
    
    try:
        # Add a small delay to appear more human-like
        time.sleep(1)
        
        response = session.get(url, timeout=15)
        response.raise_for_status()
        
        # Parse the HTML content
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # Try multiple possible selectors for the job description
        selectors = [
            'div.show-more-less-html__markup.relative.overflow-hidden',
            'div[class*="show-more-less-html__markup"]',
            'div[class*="job-description"]',
            'div[class*="description"]',
            '.description__text'
        ]
        
        target_div = None
        for selector in selectors:
            target_div = soup.select_one(selector)
            if target_div:
                break
        
        if target_div:
            # Extract all text from the div, preserving structure
            job_description = target_div.get_text(separator='\n', strip=True)
            
            # Clean up extra whitespace and empty lines
            cleaned_text = re.sub(r'\n\s*\n', '\n\n', job_description)
            cleaned_text = re.sub(r'\n{3,}', '\n\n', cleaned_text)
            
            return True, cleaned_text, ""
        else:
            return False, "", "Job description element not found on the page"
            
    except requests.exceptions.RequestException as e:
        return False, "", f"Network error: {str(e)}"
    except Exception as e:
        return False, "", f"Parsing error: {str(e)}"

@app.get("/")
async def root():
    """Root endpoint with API information"""
    return {
        "message": "LinkedIn Job Scraper API",
        "version": "1.0.0",
        "endpoints": {
            "/scrape": "POST - Scrape job description from LinkedIn URL",
            "/health": "GET - Health check endpoint",
            "/docs": "GET - API documentation"
        }
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "message": "Job scraper API is running"}

@app.post("/scrape", response_model=JobScrapingResponse)
async def scrape_job(request: JobScrapingRequest):
    """
    Scrape job description from a LinkedIn job posting URL
    
    - **url**: LinkedIn job posting URL (e.g., https://www.linkedin.com/jobs/view/123456789)
    
    Returns the job description text if successful
    """
    
    url_str = str(request.url)
    
    # Validate that it's a LinkedIn job URL
    if "linkedin.com/jobs/view/" not in url_str:
        raise HTTPException(
            status_code=400, 
            detail="Invalid URL. Please provide a LinkedIn job posting URL (e.g., https://www.linkedin.com/jobs/view/123456789)"
        )
    
    try:
        success, job_description, error_message = scrape_linkedin_job(url_str)
        
        if success:
            word_count = len(job_description.split()) if job_description else 0
            return JobScrapingResponse(
                success=True,
                job_description=job_description,
                url=url_str,
                word_count=word_count
            )
        else:
            return JobScrapingResponse(
                success=False,
                error_message=error_message,
                url=url_str
            )
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@app.get("/scrape")
async def scrape_job_get(url: str):
    """
    Alternative GET endpoint for scraping (for simple testing)
    
    - **url**: LinkedIn job posting URL
    """
    
    # Validate that it's a LinkedIn job URL
    if "linkedin.com/jobs/view/" not in url:
        raise HTTPException(
            status_code=400, 
            detail="Invalid URL. Please provide a LinkedIn job posting URL"
        )
    
    try:
        success, job_description, error_message = scrape_linkedin_job(url)
        
        if success:
            word_count = len(job_description.split()) if job_description else 0
            return {
                "success": True,
                "job_description": job_description,
                "url": url,
                "word_count": word_count
            }
        else:
            return {
                "success": False,
                "error_message": error_message,
                "url": url
            }
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

if __name__ == "__main__":
    print("Starting LinkedIn Job Scraper API...")
    print("API will be available at: http://localhost:8000")
    print("API documentation at: http://localhost:8000/docs")
    uvicorn.run(app, host="0.0.0.0", port=8000)