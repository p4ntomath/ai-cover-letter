import os
from dotenv import load_dotenv
from azure.ai.inference import ChatCompletionsClient
from azure.ai.inference.models import SystemMessage, UserMessage
from azure.core.credentials import AzureKeyCredential

# Load environment variables from .env file
load_dotenv()

endpoint = "https://models.github.ai/inference"
model = "openai/gpt-4o"

# Get GitHub token with error handling
token = os.environ.get("GITHUB_TOKEN")
if not token:
    print("❌ Error: GITHUB_TOKEN environment variable is not set!")
    print("\n🔧 To fix this, you need to:")
    print("1. Get a GitHub token from: https://github.com/settings/tokens")
    print("2. Set it as an environment variable:")
    print("   Windows (Command Prompt): set GITHUB_TOKEN=your_token_here")
    print("   Windows (PowerShell): $env:GITHUB_TOKEN='your_token_here'")
    print("   Or add it permanently through System Properties > Environment Variables")
    print("\n💡 Alternatively, you can set it directly in this script (not recommended for production):")
    print("   token = 'your_github_token_here'")
    exit(1)

client = ChatCompletionsClient(
    endpoint=endpoint,
    credential=AzureKeyCredential(token),
)

try:
    response = client.complete(
        messages=[
            SystemMessage("You are a helpful AI assistant."),
            UserMessage("What is the capital of France?"),
        ],
        temperature=1,
        top_p=1,
        model=model
    )

    print("✅ Response from GitHub AI Model:")
    print("-" * 40)
    print(response.choices[0].message.content)
    
except Exception as e:
    print(f"❌ Error calling GitHub AI API: {e}")
    print("\n🔍 Possible issues:")
    print("- Invalid GitHub token")
    print("- No access to GitHub AI models")
    print("- Network connectivity issues")
    print("- Model name might be incorrect")

