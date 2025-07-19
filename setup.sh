#!/bin/bash

echo "Installing requirements..."
pip install -r requirements.txt

echo "Downloading spaCy model..."
python -m spacy download en_core_web_sm

echo "Downloading NLTK datasets..."
python -m nltk.downloader words
python -m nltk.downloader stopwords

echo "Setup complete."
