#!/bin/bash

echo "🤖 Creating OTEL Monitoring Agent (Alternative Approach)"
echo "======================================================="

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

# Create an agent that can work with OTEL data using built-in tools
echo "🤖 Creating OTEL Monitoring Agent..."
curl -X POST "$ELASTIC_HOST/api/agent_builder/agents" \
  -H "Authorization: ApiKey $API_KEY" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "otel-health-monitor",
    "name": "OTEL Health Monitor",
    "description": "AI agent specialized in monitoring application health using OTEL data. Analyzes metrics, logs, and traces to provide real-time insights into application performance, errors, and optimization opportunities.",
    "type": "chat",
    "configuration": {
      "tools": [
        {
          "tool_ids": [
            "platform.core.search",
            "platform.core.execute_esql",
            "platform.core.generate_esql"
          ]
        }
      ]
    }
  }' \
  -w "\nStatus: %{http_code}\n"

echo ""
echo "🔍 Verifying Agent Creation..."
curl -s -H "Authorization: ApiKey $API_KEY" -H "kbn-xsrf: true" "$ELASTIC_HOST/api/agent_builder/agents" | jq '.results[] | select(.id | contains("otel")) | {id, name, type, description}'

echo ""
echo "📋 AGENT CAPABILITIES"
echo "===================="
echo "🤖 Agent: otel-health-monitor"
echo "📊 Tools Available:"
echo "  • platform.core.search - Search OTEL data in Elasticsearch"
echo "  • platform.core.execute_esql - Execute ESQL queries on OTEL data"
echo "  • platform.core.generate_esql - Generate ESQL queries for analysis"
echo ""
echo "🎯 OTEL Data Analysis Capabilities:"
echo "  • Search metrics-* indices for application metrics"
echo "  • Analyze logs-* indices for error patterns"
echo "  • Query traces-* indices for performance analysis"
echo "  • Generate ESQL queries for complex aggregations"
echo "  • Provide real-time health insights"
echo ""
echo "🔧 INTEGRATION WITH YOUR MCP SERVER"
echo "==================================="
echo "While the agent uses built-in Elastic tools, you can still:"
echo "1. Use your MCP server independently for detailed analysis"
echo "2. Create custom dashboards with your MCP insights"
echo "3. Use the agent for general OTEL queries"
echo "4. Combine agent insights with MCP server analysis"
echo ""
echo "🚀 Next Steps:"
echo "1. Start your MCP server: ./run-mcp-server.sh"
echo "2. Test the agent in Elastic UI"
echo "3. Use both agent and MCP server for comprehensive monitoring"
echo ""
echo "✅ Agent created successfully!"
