#!/bin/bash

echo "🚀 Quick MCP Server Registration with Elastic Agent Builder"
echo "==========================================================="

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

ELASTIC_HOST="$ELASTIC_ENDPOINT"
API_KEY="$ELASTIC_API_KEY"

# Check if required environment variables are set
if [ -z "$ELASTIC_ENDPOINT" ] || [ -z "$ELASTIC_API_KEY" ]; then
    echo "❌ Error: Required environment variables not set!"
    echo "Please set ELASTIC_ENDPOINT and ELASTIC_API_KEY in your .env file"
    echo "Or run: ./setup-env.sh"
    exit 1
fi

echo "📊 Registering with: $ELASTIC_HOST"
echo ""

# Simple tool registration
echo "🔧 Registering MCP Server as Tool..."
curl -X POST "$ELASTIC_HOST/api/agent_builder/tools" \
  -H "Authorization: ApiKey $API_KEY" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "elastic-otel-mcp",
    "name": "Elastic OTEL MCP Server",
    "description": "MCP server for application health monitoring",
    "type": "mcp",
    "endpoint": "http://localhost:3000",
    "tools": ["get_application_health", "get_service_metrics", "get_error_analysis"]
  }' \
  -w "\nStatus: %{http_code}\n"

echo ""
echo "🤖 Creating Monitoring Agent..."
curl -X POST "$ELASTIC_HOST/api/agent_builder/agents" \
  -H "Authorization: ApiKey $API_KEY" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "otel-agent",
    "name": "OTEL Health Monitor",
    "description": "AI agent for application health monitoring",
    "type": "chat",
    "tools": [{"tool_id": "elastic-otel-mcp", "enabled": true}],
    "instructions": "Monitor application health using OTEL data. Provide insights on performance, errors, and optimization opportunities."
  }' \
  -w "\nStatus: %{http_code}\n"

echo ""
echo "✅ Registration complete!"
echo "🔧 Next: Start your MCP server with: ./run-mcp-server.sh"
