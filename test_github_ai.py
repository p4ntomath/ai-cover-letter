import os
from dotenv import load_dotenv
from azure.ai.inference import ChatCompletionsClient
from azure.ai.inference.models import SystemMessage, UserMessage
from azure.core.credentials import AzureKeyCredential
import traceback

# Load environment variables
load_dotenv()

def test_github_ai():
    """Test GitHub AI API connection and response"""
    
    token = os.environ.get("GITHUB_TOKEN")
    print(f"Token found: {'Yes' if token else 'No'}")
    print(f"Token length: {len(token) if token else 0}")
    print(f"Token format: {token[:10] if token else 'None'}...")
    
    if not token:
        print("ERROR: No GITHUB_TOKEN found")
        return
    
    # Clean up token (remove quotes and whitespace)
    token = token.strip().strip("'\"")
    print(f"Cleaned token length: {len(token)}")
    print(f"Cleaned token format: {token[:10]}...")
    
    try:
        endpoint = "https://models.github.ai/inference"
        model = "gpt-4o"
        
        client = ChatCompletionsClient(
            endpoint=endpoint,
            credential=AzureKeyCredential(token),
        )
        
        print("Sending test request to GitHub AI...")
        
        response = client.complete(
            messages=[
                SystemMessage("You are a helpful assistant. Respond with valid JSON only."),
                UserMessage('Return this exact JSON: {"test": "success", "message": "GitHub AI is working"}'),
            ],
            temperature=0.1,
            top_p=0.9,
            model=model
        )
        
        print("Response received!")
        print(f"Response type: {type(response)}")
        print(f"Response object: {response}")
        
        if hasattr(response, 'choices') and response.choices:
            content = response.choices[0].message.content
            print(f"Content type: {type(content)}")
            print(f"Content: {content}")
        else:
            print("No choices in response")
            
    except Exception as e:
        print(f"ERROR: {str(e)}")
        print(f"Exception type: {type(e)}")
        print("Full traceback:")
        traceback.print_exc()

if __name__ == "__main__":
    test_github_ai()