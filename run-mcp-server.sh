#!/bin/bash

echo "🚀 Starting Elastic OTEL MCP Server"
echo "===================================="

# Activate virtual environment
source venv/bin/activate

# Check if arguments are provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <elastic-endpoint> <api-key>"
    echo ""
    echo "Example:"
    echo "  $0 https://otel-demo-a5630c.kb.us-east-1.aws.elastic.cloud ZktNNGJaa0JxTVdyT0R5UlpCR2w6bzNtZTV5eVRicVJlV21hRmN0TVBvZw=="
    echo ""
    echo "Or run with default demo credentials:"
    echo "  $0 demo"
    exit 1
fi

# Use demo credentials if "demo" is passed
if [ "$1" = "demo" ]; then
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
