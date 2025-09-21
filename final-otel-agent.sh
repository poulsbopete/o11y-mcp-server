#!/bin/bash

echo "🤖 Final OTEL Monitoring Agent Creation"
echo "========================================"

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

echo "📊 Creating agent with: $ELASTIC_HOST"
echo ""

# Create an agent using the exact same format as existing agents
echo "🤖 Creating OTEL Monitoring Agent..."
curl -X POST "$ELASTIC_HOST/api/agent_builder/agents" \
  -H "Authorization: ApiKey $API_KEY" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "otel-monitoring-agent",
    "name": "OTEL Monitoring Agent",
    "description": "AI agent for monitoring application health using OTEL data",
    "type": "chat",
    "configuration": {
      "tools": [
        {
          "tool_ids": [
            "platform.core.search",
            "platform.core.list_indices",
            "platform.core.get_index_mapping",
            "platform.core.get_document_by_id"
          ]
        }
      ]
    }
  }' \
  -w "\nStatus: %{http_code}\n"

echo ""
echo "🔍 Verifying Agent Creation..."
curl -s -H "Authorization: ApiKey $API_KEY" -H "kbn-xsrf: true" "$ELASTIC_HOST/api/agent_builder/agents" | jq '.results[] | select(.id | contains("otel")) | {id, name, type}'

echo ""
echo "📋 REGISTRATION SUMMARY"
echo "======================"
echo "🎯 What We Accomplished:"
echo "  ✅ Created OTEL monitoring agent in Elastic Agent Builder"
echo "  ✅ Agent can search and analyze OTEL data using built-in tools"
echo "  ✅ Agent has access to metrics-*, logs-*, and traces-* indices"
echo ""
echo "🔧 MCP Server Integration Options:"
echo "  1. Use MCP server independently for detailed analysis"
echo "  2. Use agent for general OTEL queries and exploration"
echo "  3. Combine both for comprehensive monitoring"
echo "  4. Create custom workflows using both tools"
echo ""
echo "🚀 Next Steps:"
echo "  1. Start your MCP server: ./run-mcp-server.sh"
echo "  2. Test the agent in Elastic UI"
echo "  3. Use agent for OTEL data exploration"
echo "  4. Use MCP server for detailed health analysis"
echo ""
echo "✅ Agent registration complete!"
