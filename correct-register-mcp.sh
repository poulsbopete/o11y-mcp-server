#!/bin/bash

echo "🔧 Corrected MCP Server Registration with Elastic Agent Builder"
echo "==============================================================="

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

# First, let's see what tools are available
echo "🔍 Checking existing tools..."
curl -s -H "Authorization: ApiKey $API_KEY" -H "kbn-xsrf: true" "$ELASTIC_HOST/api/agent_builder/tools" | jq '.results | length'
echo ""

# Register MCP server as a custom tool (using the correct format)
echo "🔧 Registering MCP Server as Custom Tool..."
curl -X POST "$ELASTIC_HOST/api/agent_builder/tools" \
  -H "Authorization: ApiKey $API_KEY" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "elastic-otel-mcp-server",
    "name": "Elastic OTEL MCP Server",
    "description": "MCP server providing real-time application health insights from OTEL data. Offers 7 powerful tools for analyzing application health, performance, errors, and optimization opportunities.",
    "type": "custom",
    "category": "observability",
    "schema": {
      "type": "object",
      "properties": {
        "tool_name": {
          "type": "string",
          "description": "Name of the MCP tool to call",
          "enum": [
            "get_application_health",
            "get_service_metrics",
            "get_error_analysis", 
            "get_performance_issues",
            "get_resource_utilization",
            "get_trace_analysis",
            "get_code_recommendations"
          ]
        },
        "parameters": {
          "type": "object",
          "description": "Parameters for the MCP tool call",
          "properties": {
            "time_range": {
              "type": "string",
              "description": "Time range for analysis (e.g., 15m, 1h, 1d)",
              "default": "15m"
            },
            "service_name": {
              "type": "string", 
              "description": "Name of the service to analyze (for service-specific tools)"
            },
            "severity": {
              "type": "string",
              "description": "Error severity level (ERROR, WARN, INFO)",
              "default": "ERROR"
            },
            "threshold_ms": {
              "type": "number",
              "description": "Performance threshold in milliseconds",
              "default": 1000
            },
            "resource_type": {
              "type": "string",
              "description": "Type of resource to analyze",
              "default": "all"
            },
            "operation_name": {
              "type": "string",
              "description": "Name of the operation to analyze"
            },
            "focus_area": {
              "type": "string",
              "description": "Focus area for recommendations",
              "default": "performance"
            }
          }
        }
      },
      "required": ["tool_name"]
    }
  }' \
  -w "\nStatus: %{http_code}\n"

echo ""
echo "🤖 Creating OTEL Monitoring Agent..."
curl -X POST "$ELASTIC_HOST/api/agent_builder/agents" \
  -H "Authorization: ApiKey $API_KEY" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "otel-monitoring-agent",
    "name": "OTEL Health Monitor",
    "description": "AI agent specialized in monitoring application health using OTEL data. Provides real-time insights into application performance, errors, and optimization opportunities.",
    "type": "chat",
    "configuration": {
      "tools": [
        {
          "tool_ids": [
            "elastic-otel-mcp-server",
            "platform.core.search"
          ]
        }
      ]
    }
  }' \
  -w "\nStatus: %{http_code}\n"

echo ""
echo "🔍 Verifying Registration..."
echo "Tools:"
curl -s -H "Authorization: ApiKey $API_KEY" -H "kbn-xsrf: true" "$ELASTIC_HOST/api/agent_builder/tools" | jq '.results[] | select(.id | contains("elastic-otel")) | {id, name, type}'

echo ""
echo "Agents:"
curl -s -H "Authorization: ApiKey $API_KEY" -H "kbn-xsrf: true" "$ELASTIC_HOST/api/agent_builder/agents" | jq '.results[] | select(.id | contains("otel")) | {id, name, type}'

echo ""
echo "✅ Registration Summary:"
echo "🔧 MCP Server Tool: elastic-otel-mcp-server"
echo "🤖 Monitoring Agent: otel-monitoring-agent"
echo "📊 Integration: Agent can now use MCP server tools"
echo ""
echo "🚀 Next Steps:"
echo "1. Start your MCP server: ./run-mcp-server.sh"
echo "2. Test the agent in Elastic UI"
echo "3. Use the agent for application health monitoring"
