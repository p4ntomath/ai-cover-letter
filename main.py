from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware

# Import sub-apps
from job_scraper_api import app as job_scraper_app
from cover_letter_api import app as cover_letter_app
from text_extractor_api import app as text_extractor_app
from ai_cover_letter_api import app as ai_cover_app

app = FastAPI()

# Mount APIs
app.mount("/api/scraper", job_scraper_app)
app.mount("/api/cover", cover_letter_app)
app.mount("/api/extract", text_extractor_app)
app.mount("/api/ai", ai_cover_app)

