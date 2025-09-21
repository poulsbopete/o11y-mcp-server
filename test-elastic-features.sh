#!/bin/bash

echo "🔍 Testing Elastic Serverless Features"
echo "====================================="

# Load environment variables from .env file if it exists
if [ -f .env ]; then
    echo "📄 Loading environment variables from .env file..."
    export $(cat .env | grep -v '^#' | xargs)
fi

# Configuration - use environment variables with fallbacks
ELASTIC_HOST="${ELASTIC_ENDPOINT:-https://otel-demo-a5630c.kb.us-east-1.aws.elastic.cloud}"
API_KEY="${ELASTIC_API_KEY:-ZktNNGJaa0JxTVdyT0R5UlpCR2w6bzNtZTV5eVRicVJlV21hRmN0TVBvZw==}"

echo "📊 Elastic Instance: $ELASTIC_HOST"
echo "🔑 API Key: ${API_KEY:0:20}..."
echo ""

# Function to test an endpoint
test_endpoint() {
    local endpoint="$1"
    local method="${2:-GET}"
    local body="$3"
    local description="$4"
    
    echo "🔍 Testing: $method $endpoint"
    if [ -n "$description" ]; then
        echo "   📝 $description"
    fi
    
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
    
    if [ "$http_code" = "200" ]; then
        echo "   ✅ SUCCESS!"
        echo "   Response: ${body:0:300}..."
        return 0
    elif [ "$http_code" = "401" ]; then
        echo "   🔐 Auth required"
    elif [ "$http_code" = "403" ]; then
        echo "   ❌ Forbidden"
    elif [ "$http_code" = "404" ]; then
        echo "   🔍 Not found"
    elif [ "$http_code" = "400" ]; then
        echo "   ⚠️ 400 Error: ${body:0:100}..."
    else
        echo "   ❌ Error: $http_code"
    fi
    
    return 1
}

echo "🧪 TESTING 1CHAT FEATURES"
echo "-------------------------"

# Test 1Chat endpoints based on settings
onechat_endpoints=(
    "/api/onechat"
    "/api/onechat/agents"
    "/api/onechat/tools"
    "/api/onechat/conversations"
    "/api/onechat/sessions"
    "/internal/onechat"
    "/internal/onechat/agents"
    "/internal/onechat/tools"
    "/api/chat/onechat"
    "/internal/chat/onechat"
)

for endpoint in "${onechat_endpoints[@]}"; do
    test_endpoint "$endpoint" "GET" "" "1Chat endpoint"
done

echo ""
echo "🧪 TESTING AGENT BUILDER FEATURES"
echo "--------------------------------"

# Test Agent Builder endpoints
agent_builder_endpoints=(
    "/api/agent_builder"
    "/api/agent_builder/agents"
    "/api/agent_builder/tools"
    "/api/agent_builder/models"
    "/api/agent_builder/configs"
    "/internal/agent_builder"
    "/internal/agent_builder/agents"
    "/internal/agent_builder/tools"
    "/api/agent-builder"
    "/api/agent-builder/agents"
    "/api/agent-builder/tools"
)

for endpoint in "${agent_builder_endpoints[@]}"; do
    test_endpoint "$endpoint" "GET" "" "Agent Builder endpoint"
done

echo ""
echo "🧪 TESTING MCP FEATURES"
echo "----------------------"

# Test MCP-specific endpoints (since onechat:mcp:enabled is true)
mcp_endpoints=(
    "/api/onechat/mcp"
    "/api/onechat/mcp/servers"
    "/api/onechat/mcp/tools"
    "/api/onechat/mcp/resources"
    "/internal/onechat/mcp"
    "/internal/onechat/mcp/servers"
    "/api/chat/mcp"
    "/internal/chat/mcp"
)

for endpoint in "${mcp_endpoints[@]}"; do
    test_endpoint "$endpoint" "GET" "" "MCP endpoint"
done

echo ""
echo "🧪 TESTING A2A FEATURES"
echo "----------------------"

# Test A2A (Agent-to-Agent) endpoints
a2a_endpoints=(
    "/api/onechat/a2a"
    "/api/onechat/a2a/agents"
    "/api/onechat/a2a/connections"
    "/internal/onechat/a2a"
    "/internal/onechat/a2a/agents"
)

for endpoint in "${a2a_endpoints[@]}"; do
    test_endpoint "$endpoint" "GET" "" "A2A endpoint"
done

echo ""
echo "🧪 TESTING POST ENDPOINTS"
echo "------------------------"

# Test POST endpoints for creating resources
echo "🔧 Testing Agent Creation:"
test_endpoint "/api/agent_builder/agents" "POST" '{"name":"test-agent","description":"Test agent","type":"chat"}' "Create agent"

echo ""
echo "🔧 Testing 1Chat Agent Creation:"
test_endpoint "/api/onechat/agents" "POST" '{"name":"test-onechat-agent","description":"Test 1Chat agent","type":"chat"}' "Create 1Chat agent"

echo ""
echo "🔧 Testing MCP Server Registration:"
test_endpoint "/api/onechat/mcp/servers" "POST" '{"name":"test-mcp-server","endpoint":"http://localhost:3000","tools":["get_application_health"]}' "Register MCP server"

echo ""
echo "📋 FEATURE ANALYSIS SUMMARY"
echo "=========================="
echo "🔍 ENABLED FEATURES (from settings):"
echo "  ✅ onechat:mcp:enabled = true"
echo "  ✅ onechat:a2a:enabled = true" 
echo "  ✅ onechat:api:enabled = true"
echo "  ✅ onechat:ui:enabled = true"
echo "  ✅ agentBuilder:enabled = true"
echo ""
echo "🎯 EXPECTED CAPABILITIES:"
echo "  • 1Chat API endpoints for conversational AI"
echo "  • Agent Builder for creating custom agents"
echo "  • MCP (Model Context Protocol) integration"
echo "  • A2A (Agent-to-Agent) communication"
echo "  • Tool management and execution"
echo ""
echo "🔧 INTEGRATION OPPORTUNITIES:"
echo "  • Your MCP server can integrate with 1Chat"
echo "  • Agent Builder can create agents that use your MCP tools"
echo "  • A2A allows agents to communicate with each other"
echo "  • MCP enables external tool integration"
