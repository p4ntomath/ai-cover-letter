#!/bin/bash

# Exit on error
set -e

echo "🔧 Activating virtual environment..."
source venv/bin/activate

mkdir -p logs

echo "🚀 Starting job_scraper_api on port 8000..."
nohup uvicorn job_scraper_api:app --host 0.0.0.0 --port 8000 > logs/job_scraper.log 2>&1 &

echo "🚀 Starting cover_letter_api on port 8001..."
nohup uvicorn cover_letter_api:app --host 0.0.0.0 --port 8001 > logs/cover_letter.log 2>&1 &

echo "🚀 Starting text_extractor_api on port 8002..."
nohup uvicorn text_extractor_api:app --host 0.0.0.0 --port 8002 > logs/text_extractor.log 2>&1 &

echo "🚀 Starting ai_cover_letter_api on port 8003..."
nohup uvicorn ai_cover_letter_api:app --host 0.0.0.0 --port 8003 > logs/ai_cover_letter.log 2>&1 &

echo "🧾 Serving index.html on port 8080..."
nohup python3 -m http.server 8080 > logs/frontend.log 2>&1 &

echo "✅ All services started."
