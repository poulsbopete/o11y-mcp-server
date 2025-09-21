#!/bin/bash

echo "🚀 Starting Elastic OTEL MCP Server"
echo "===================================="

# Activate virtual environment
source venv/bin/activate

# Load environment variables from .env file if it exists
if [ -f .env ]; then
    echo "📄 Loading environment variables from .env file..."
    export $(cat .env | grep -v '^#' | xargs)
fi

# Check if environment variables are set
if [ -n "$ELASTIC_ENDPOINT" ] && [ -n "$ELASTIC_API_KEY" ]; then
    echo "✅ Using environment variables"
    ELASTIC_ENDPOINT="$ELASTIC_ENDPOINT"
    API_KEY="$ELASTIC_API_KEY"
elif [ $# -eq 0 ]; then
    echo "❌ No credentials provided!"
    echo ""
    echo "Usage options:"
    echo "1. Set environment variables:"
    echo "   export ELASTIC_ENDPOINT=https://your-endpoint.kb.us-east-1.aws.elastic.cloud"
    echo "   export ELASTIC_API_KEY=your-api-key"
    echo "   $0"
    echo ""
    echo "2. Use .env file:"
    echo "   Create .env file with ELASTIC_ENDPOINT and ELASTIC_API_KEY"
    echo "   $0"
    echo ""
    echo "3. Pass credentials as arguments:"
    echo "   $0 <elastic-endpoint> <api-key>"
    echo ""
    echo "4. Use demo credentials:"
    echo "   $0 demo"
    exit 1
elif [ "$1" = "demo" ]; then
    echo "🎯 Using demo credentials"
    ELASTIC_ENDPOINT="https://otel-demo-a5630c.kb.us-east-1.aws.elastic.cloud"
    API_KEY="ZktNNGJaa0JxTVdyT0R5UlpCR2w6bzNtZTV5eVRicVJlV21hRmN0TVBvZw=="
else
    ELASTIC_ENDPOINT="$1"
    API_KEY="$2"
fi

echo "📊 Elastic Endpoint: $ELASTIC_ENDPOINT"
echo "🔑 API Key: ${API_KEY:0:20}..."
echo ""
echo "🎯 Available MCP Tools:"
echo "  - get_application_health: Get overall application health status"
echo "  - get_service_metrics: Get metrics for specific services"
echo "  - get_error_analysis: Analyze errors and exceptions"
echo "  - get_performance_issues: Identify performance bottlenecks"
echo "  - get_resource_utilization: Monitor CPU, memory, and resource usage"
echo "  - get_trace_analysis: Analyze distributed traces"
echo "  - get_code_recommendations: Get optimization recommendations"
echo ""
echo "🔧 Starting MCP Server..."
echo ""

# Run the MCP server
python3 elastic-otel-mcp-server.py "$ELASTIC_ENDPOINT" "$API_KEY"
