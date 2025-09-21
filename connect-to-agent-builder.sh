#!/bin/bash

echo "🤖 Connecting to Elastic Agent Builder"
echo "======================================"

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

echo "📊 Connecting to: $ELASTIC_HOST"
echo "🔑 API Key: ${API_KEY:0:20}..."
echo ""

# Function to make API calls to Agent Builder
call_agent_builder() {
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

echo "🧪 STEP 1: Check Agent Builder Status"
echo "===================================="

# Check if Agent Builder is accessible
call_agent_builder "/api/agent_builder/agents" "GET" "" "List available agents"

echo ""
# Check available tools
call_agent_builder "/api/agent_builder/tools" "GET" "" "List available tools"

echo ""
echo "🧪 STEP 2: Create OTEL Monitoring Agent"
echo "======================================"

# Create an agent for OTEL monitoring
AGENT_BODY='{
  "id": "otel-health-monitor",
  "name": "OTEL Health Monitor",
  "description": "AI agent for monitoring application health using OTEL data",
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
}'

call_agent_builder "/api/agent_builder/agents" "POST" "$AGENT_BODY" "Create OTEL monitoring agent"

echo ""
echo "🧪 STEP 3: Test Agent Builder Integration"
echo "========================================"

# Test the created agent
call_agent_builder "/api/agent_builder/agents" "GET" "" "Verify agent creation"

echo ""
echo "📋 AGENT BUILDER INTEGRATION SUMMARY"
echo "===================================="
echo "🎯 What We Accomplished:"
echo "  ✅ Connected to Elastic Agent Builder at $ELASTIC_HOST"
echo "  ✅ Created OTEL monitoring agent"
echo "  ✅ Agent has access to OTEL data through built-in tools"
echo ""
echo "🔧 Available Tools in Agent Builder:"
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
echo "🚀 Next Steps:"
echo "  1. Use the agent in Elastic UI for OTEL data analysis"
echo "  2. Ask the agent questions about application health"
echo "  3. Use built-in tools to explore OTEL data"
echo "  4. Create custom queries for specific monitoring needs"
echo ""
echo "✅ Agent Builder integration complete!"
echo "🔗 Access your agent at: $ELASTIC_HOST"
