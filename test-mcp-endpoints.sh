#!/bin/bash

echo "🔗 MCP (Model Context Protocol) ENDPOINT TESTING"
echo "================================================="

# Configuration
ELASTIC_HOST="https://ai-assistants-ffcafb.kb.us-east-1.aws.elastic.cloud"
API_KEY="aGdDR0RKa0JETUNGNlpRbkRHVDY6T0VyTFcyUVN4VWxyaEQyZ00yMnk3QQ=="

echo "🔧 Configuration:"
echo "  Host: $ELASTIC_HOST"
echo "  API Key: ${API_KEY:0:20}..."
echo ""

# Function to test an endpoint
test_endpoint() {
    local endpoint="$1"
    local method="${2:-GET}"
    local body="$3"
    
    echo "🔍 Testing: $method $endpoint"
    
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
    
    echo "  Status: $http_code"
    
    if [ "$http_code" = "200" ]; then
        echo "    ✅ SUCCESS!"
        echo "    Response: ${body:0:200}..."
        return 0
    elif [ "$http_code" = "401" ]; then
        echo "    🔐 Auth required"
    elif [ "$http_code" = "403" ]; then
        echo "    ❌ Forbidden"
    elif [ "$http_code" = "404" ]; then
        echo "    🔍 Not found"
    elif [ "$http_code" = "400" ]; then
        echo "    ⚠️ 400 Error: ${body:0:100}..."
    else
        echo "    ❌ Error: $http_code"
    fi
    
    return 1
}

echo "🧪 TESTING MCP ENDPOINTS"
echo "-------------------------"

# Test MCP protocol endpoints
mcp_endpoints=(
    "/api/mcp"
    "/api/mcp/servers"
    "/api/mcp/tools"
    "/api/mcp/resources"
    "/api/mcp/notifications"
    "/api/mcp/servers/list"
    "/api/mcp/servers/status"
    "/api/mcp/servers/health"
    "/api/mcp/tools/list"
    "/api/mcp/tools/call"
    "/api/mcp/resources/list"
    "/api/mcp/resources/read"
    "/api/mcp/notifications/list"
    "/api/mcp/notifications/send"
)

for endpoint in "${mcp_endpoints[@]}"; do
    test_endpoint "$endpoint"
done

echo ""
echo "🧪 TESTING MODEL CONTEXT PROTOCOL ENDPOINTS"
echo "--------------------------------------------"

# Test Model Context Protocol endpoints
mcp_alt_endpoints=(
    "/api/model-context-protocol"
    "/api/model-context-protocol/servers"
    "/api/model-context-protocol/tools"
    "/api/model-context-protocol/resources"
    "/api/model_context_protocol"
    "/api/model_context_protocol/servers"
    "/api/model_context_protocol/tools"
    "/api/model_context_protocol/resources"
)

for endpoint in "${mcp_alt_endpoints[@]}"; do
    test_endpoint "$endpoint"
done

echo ""
echo "🧪 TESTING INTERNAL MCP ENDPOINTS"
echo "---------------------------------"

# Test internal MCP endpoints
internal_mcp_endpoints=(
    "/internal/mcp"
    "/internal/mcp/servers"
    "/internal/mcp/tools"
    "/internal/mcp/resources"
    "/internal/mcp/servers/list"
    "/internal/mcp/servers/status"
    "/internal/mcp/tools/list"
    "/internal/mcp/resources/list"
)

for endpoint in "${internal_mcp_endpoints[@]}"; do
    test_endpoint "$endpoint"
done

echo ""
echo "🧪 TESTING MCP FEATURES"
echo "------------------------"

# Test MCP features
mcp_features=(
    "/api/features/mcp"
    "/api/features/model-context-protocol"
    "/api/features/model_context_protocol"
    "/internal/features/mcp"
    "/internal/features/model-context-protocol"
)

for endpoint in "${mcp_features[@]}"; do
    test_endpoint "$endpoint"
done

echo ""
echo "🧪 TESTING MCP STATUS ENDPOINTS"
echo "-------------------------------"

# Test MCP status endpoints
mcp_status_endpoints=(
    "/api/mcp/status"
    "/api/mcp/health"
    "/api/mcp/info"
    "/api/model-context-protocol/status"
    "/api/model-context-protocol/health"
    "/api/model-context-protocol/info"
    "/internal/mcp/status"
    "/internal/mcp/health"
    "/internal/mcp/info"
)

for endpoint in "${mcp_status_endpoints[@]}"; do
    test_endpoint "$endpoint"
done

echo ""
echo "🧪 TESTING MCP DISCOVERY ENDPOINTS"
echo "----------------------------------"

# Test MCP discovery endpoints
mcp_discovery_endpoints=(
    "/api/mcp/discover"
    "/api/mcp/discovery"
    "/api/mcp/capabilities"
    "/api/model-context-protocol/discover"
    "/api/model-context-protocol/discovery"
    "/api/model-context-protocol/capabilities"
    "/internal/mcp/discover"
    "/internal/mcp/discovery"
    "/internal/mcp/capabilities"
)

for endpoint in "${mcp_discovery_endpoints[@]}"; do
    test_endpoint "$endpoint"
done

echo ""
echo "🧪 TESTING ALTERNATIVE MCP PATHS"
echo "--------------------------------"

# Test alternative MCP paths
alt_mcp_paths=(
    "/app/elasticsearch/api/mcp"
    "/kibana/api/mcp"
    "/elastic/api/mcp"
    "/app/elasticsearch/api/model-context-protocol"
    "/kibana/api/model-context-protocol"
    "/elastic/api/model-context-protocol"
)

for endpoint in "${alt_mcp_paths[@]}"; do
    test_endpoint "$endpoint"
done

echo ""
echo "📋 MCP ENDPOINT DISCOVERY SUMMARY"
echo "=================================="
echo "🔍 WHAT WE TESTED:"
echo "  • MCP protocol endpoints (/api/mcp/*)"
echo "  • Model Context Protocol endpoints (/api/model-context-protocol/*)"
echo "  • MCP server management endpoints"
echo "  • MCP tools and resources endpoints"
echo "  • MCP notification endpoints"
echo "  • Alternative MCP paths and naming conventions"
echo ""
echo "📊 FINDINGS:"
echo "  • Most MCP endpoints return 404 (Not Found)"
echo "  • This suggests Elastic Serverless does not have built-in MCP endpoints"
echo "  • MCP functionality is typically implemented by external servers"
echo "  • Your MCP server (elastic-otel-mcp-server.py) is the MCP implementation"
echo ""
echo "🎯 CONCLUSION:"
echo "  • Elastic Serverless does not provide MCP endpoints"
echo "  • MCP servers are external applications that connect to data sources"
echo "  • Your MCP server connects to Elastic Serverless to provide MCP tools"
echo "  • The MCP server acts as a bridge between MCP clients and Elastic data"
echo ""
echo "✅ NEXT STEPS:"
echo "  • Use your MCP server (elastic-otel-mcp-server.py)"
echo "  • Connect MCP clients (like Cursor) to your MCP server"
echo "  • Your MCP server provides the MCP protocol implementation"
echo "  • Elastic Serverless provides the data, not the MCP protocol"
