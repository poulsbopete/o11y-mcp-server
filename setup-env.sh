#!/bin/bash

echo "🔐 Setting up environment variables for MCP Server"
echo "=================================================="

# Check if .env file already exists
if [ -f .env ]; then
    echo "⚠️  .env file already exists!"
    echo "Do you want to overwrite it? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "❌ Setup cancelled"
        exit 0
    fi
fi

echo "📝 Creating .env file..."

# Create .env file with template
cat > .env << 'EOF'
# Elastic Serverless Observability Configuration
ELASTIC_ENDPOINT=https://your-elastic-endpoint.kb.us-east-1.aws.elastic.cloud
ELASTIC_API_KEY=your-elastic-api-key-here

# Optional: Logging Configuration
LOG_LEVEL=INFO
ELASTIC_TIMEOUT=30
EOF

echo "✅ .env file created!"
echo ""
echo "🔧 Next steps:"
echo "1. Edit .env file with your actual credentials:"
echo "   nano .env"
echo ""
echo "2. Or use demo credentials:"
echo "   sed -i 's|https://your-elastic-endpoint.kb.us-east-1.aws.elastic.cloud|https://otel-demo-a5630c.kb.us-east-1.aws.elastic.cloud|' .env"
echo "   sed -i 's|your-elastic-api-key-here|ZktNNGJaa0JxTVdyT0R5UlpCR2w6bzNtZTV5eVRicVJlV21hRmN0TVBvZw==|' .env"
echo ""
echo "3. Run the MCP server:"
echo "   ./run-mcp-server.sh"
echo ""
echo "🔒 Security note:"
echo "   - .env file is in .gitignore (won't be committed to git)"
echo "   - Never commit API keys to public repositories"
echo "   - Use env.example as a template for others"
