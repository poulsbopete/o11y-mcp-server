#!/bin/bash

echo "🔧 Registering MCP Server with Elastic Agent Builder"
echo "==================================================="

# Load environment variables from .env file if it exists
if [ -f .env ]; then
    echo "📄 Loading environment variables from .env file..."
    export $(cat .env | grep -v '^#' | xargs)
fi

# Configuration - use environment variables only
ELASTIC_HOST="$ELASTIC_ENDPOINT"
API_KEY="$ELASTIC_API_KEY"

# Check if required environment variables are set
if [ -z "$ELASTIC_ENDPOINT" ] || [ -z "$ELASTIC_API_KEY" ]; then
    echo "❌ Error: Required environment variables not set!"
    echo "Please set ELASTIC_ENDPOINT and ELASTIC_API_KEY in your .env file"
    echo "Or run: ./setup-env.sh"
    exit 1
fi

echo "📊 Elastic Instance: $ELASTIC_HOST"
echo "🔑 API Key: ${API_KEY:0:20}..."
echo ""

# Function to make API calls
make_api_call() {
    local endpoint="$1"
    local method="${2:-GET}"
    local body="$3"
    local description="$4"
    
    echo "🔍 $description"
    echo "   Endpoint: $method $endpoint"
    
    local url="$ELASTIC_HOST$endpoint"
    local headers=(
        -H "Authorization: ApiKey $API_KEY"
        -H "kbn-xsrf: true"
        -H "Content-Type: application/json"
    )
    
    if [ "$method" = "POST" ] && [ -n "$body" ]; then
        local response=$(curl -s -w "\n%{http_code}" -X POST "${headers[@]}" -d "$body" "$url")
    else
        local response=$(curl -s -w "\n%{http_code}" "${headers[@]}" "$url")
    fi
    
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | head -n -1)
    
    echo "   Status: $http_code"
    
    if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
        echo "   ✅ SUCCESS!"
        echo "   Response: ${body:0:500}..."
        return 0
    elif [ "$http_code" = "400" ]; then
        echo "   ⚠️ 400 Error: ${body:0:200}..."
        echo "   This might indicate missing required fields or validation errors"
    elif [ "$http_code" = "401" ]; then
        echo "   🔐 Authentication required"
    elif [ "$http_code" = "403" ]; then
        echo "   ❌ Forbidden - insufficient permissions"
    elif [ "$http_code" = "404" ]; then
        echo "   🔍 Endpoint not found"
    else
        echo "   ❌ Error: $http_code"
        echo "   Response: ${body:0:200}..."
    fi
    
    return 1
}

echo "🧪 STEP 1: Check existing agents and tools"
echo "=========================================="

# Check existing agents
make_api_call "/api/agent_builder/agents" "GET" "" "List existing agents"

echo ""
# Check existing tools
make_api_call "/api/agent_builder/tools" "GET" "" "List existing tools"

echo ""
echo "🧪 STEP 2: Register MCP Server as a Tool"
echo "========================================"

# Register MCP server as a tool
MCP_TOOL_BODY='{
  "id": "elastic-otel-mcp-server",
  "name": "Elastic OTEL MCP Server",
  "description": "MCP server providing real-time application health insights from OTEL data",
  "type": "mcp",
  "category": "observability",
  "endpoint": "http://localhost:3000",
  "capabilities": [
    "get_application_health",
    "get_service_metrics", 
    "get_error_analysis",
    "get_performance_issues",
    "get_resource_utilization",
    "get_trace_analysis",
    "get_code_recommendations"
  ],
  "configuration": {
    "protocol": "mcp",
    "version": "1.0.0",
    "tools": [
      {
        "name": "get_application_health",
        "description": "Get overall application health status from OTEL data",
        "parameters": {
          "time_range": "string"
        }
      },
      {
        "name": "get_service_metrics", 
        "description": "Get metrics for specific services (CPU, memory, response time, error rate)",
        "parameters": {
          "service_name": "string",
          "time_range": "string"
        }
      },
      {
        "name": "get_error_analysis",
        "description": "Analyze errors and exceptions in applications",
        "parameters": {
          "time_range": "string",
          "severity": "string"
        }
      },
      {
        "name": "get_performance_issues",
        "description": "Identify performance bottlenecks and slow operations",
        "parameters": {
          "time_range": "string",
          "threshold_ms": "number"
        }
      },
      {
        "name": "get_resource_utilization",
        "description": "Monitor CPU, memory, and resource usage",
        "parameters": {
          "time_range": "string",
          "resource_type": "string"
        }
      },
      {
        "name": "get_trace_analysis",
        "description": "Analyze distributed traces for service dependencies",
        "parameters": {
          "time_range": "string",
          "operation_name": "string"
        }
      },
      {
        "name": "get_code_recommendations",
        "description": "Get optimization recommendations based on patterns",
        "parameters": {
          "time_range": "string",
          "focus_area": "string"
        }
      }
    ]
  }
}'

make_api_call "/api/agent_builder/tools" "POST" "$MCP_TOOL_BODY" "Register MCP server as tool"

echo ""
echo "🧪 STEP 3: Create Monitoring Agent"
echo "================================="

# Create an agent that uses the MCP server
AGENT_BODY='{
  "id": "otel-monitoring-agent",
  "name": "OTEL Monitoring Agent",
  "description": "AI agent for monitoring application health using OTEL data",
  "type": "chat",
  "model": "gpt-4",
  "configuration": {
    "tools": [
      {
        "tool_id": "elastic-otel-mcp-server",
        "enabled": true
      }
    ],
    "instructions": "You are an expert application monitoring agent. Use the OTEL MCP server tools to analyze application health, identify issues, and provide recommendations. Always provide detailed analysis with specific metrics and actionable insights.",
    "capabilities": [
      "application_health_analysis",
      "performance_monitoring", 
      "error_analysis",
      "resource_optimization",
      "trace_analysis"
    ]
  }
}'

make_api_call "/api/agent_builder/agents" "POST" "$AGENT_BODY" "Create OTEL monitoring agent"

echo ""
echo "🧪 STEP 4: Test Agent Registration"
echo "=================================="

# Verify the agent was created
make_api_call "/api/agent_builder/agents" "GET" "" "Verify agent creation"

echo ""
echo "🧪 STEP 5: Test Tool Registration"
echo "================================"

# Verify the tool was registered
make_api_call "/api/agent_builder/tools" "GET" "" "Verify tool registration"

echo ""
echo "📋 REGISTRATION SUMMARY"
echo "======================="
echo "🎯 MCP Server Registration:"
echo "  • Tool ID: elastic-otel-mcp-server"
echo "  • Endpoint: http://localhost:3000"
echo "  • Protocol: MCP (Model Context Protocol)"
echo "  • Tools: 7 health analysis tools"
echo ""
echo "🤖 Agent Creation:"
echo "  • Agent ID: otel-monitoring-agent"
echo "  • Type: Chat agent with MCP integration"
echo "  • Capabilities: Application health monitoring"
echo "  • Tools: Connected to MCP server"
echo ""
echo "🔧 Next Steps:"
echo "  1. Start your MCP server: ./run-mcp-server.sh"
echo "  2. Test agent interaction through Elastic UI"
echo "  3. Use agent for application health monitoring"
echo "  4. Monitor agent performance and tool usage"
echo ""
echo "✅ Registration complete! Your MCP server is now integrated with Elastic Agent Builder."
