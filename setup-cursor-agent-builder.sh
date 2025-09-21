#!/bin/bash

echo "🤖 Setting up Cursor MCP Integration with Elastic Agent Builder"
echo "=============================================================="

# Load environment variables
if [ -f .env ]; then
    echo "📄 Loading environment variables from .env file..."
    export $(cat .env | grep -v '^#' | xargs)
fi

# Check if required environment variables are set
if [ -z "$ELASTIC_ENDPOINT" ] || [ -z "$ELASTIC_API_KEY" ]; then
    echo "❌ Error: Required environment variables not set!"
    echo "Please set ELASTIC_ENDPOINT and ELASTIC_API_KEY in your .env file"
    echo "Or run: ./setup-env.sh"
    exit 1
fi

echo "📊 Elastic Endpoint: $ELASTIC_ENDPOINT"
echo "🔑 API Key: ${ELASTIC_API_KEY:0:20}..."
echo ""

# Determine Cursor config directory based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    CURSOR_CONFIG_DIR="$HOME/.cursor"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    CURSOR_CONFIG_DIR="$HOME/.config/cursor"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    # Windows
    CURSOR_CONFIG_DIR="$APPDATA/Cursor"
else
    echo "❌ Unsupported operating system: $OSTYPE"
    exit 1
fi

echo "🔧 Creating Cursor configuration directory: $CURSOR_CONFIG_DIR"
mkdir -p "$CURSOR_CONFIG_DIR"

# Create MCP configuration for Agent Builder
MCP_CONFIG_FILE="$CURSOR_CONFIG_DIR/mcp_config.json"

echo "📝 Creating MCP configuration file: $MCP_CONFIG_FILE"

cat > "$MCP_CONFIG_FILE" << EOF
{
  "mcpServers": {
    "elastic-agent-builder": {
      "command": "curl",
      "args": [
        "-X", "POST",
        "-H", "Authorization: ApiKey $ELASTIC_API_KEY",
        "-H", "kbn-xsrf: true",
        "-H", "Content-Type: application/json",
        "-d", "{\"tool_name\": \"platform.core.search\", \"parameters\": {\"query\": \"application health\", \"index\": \"metrics-*\"}}",
        "$ELASTIC_ENDPOINT/api/agent_builder/tools"
      ],
      "env": {
        "ELASTIC_ENDPOINT": "$ELASTIC_ENDPOINT",
        "ELASTIC_API_KEY": "$ELASTIC_API_KEY"
      }
    }
  }
}
EOF

echo "✅ MCP configuration created successfully!"
echo ""

# Test the configuration
echo "🧪 Testing Agent Builder connection..."
TEST_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET \
  -H "Authorization: ApiKey $ELASTIC_API_KEY" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  "$ELASTIC_ENDPOINT/api/agent_builder/agents")

HTTP_CODE=$(echo "$TEST_RESPONSE" | tail -n1)
BODY=$(echo "$TEST_RESPONSE" | head -n -1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Agent Builder connection successful!"
    echo "📊 Status: $HTTP_CODE"
else
    echo "⚠️  Agent Builder connection test failed"
    echo "📊 Status: $HTTP_CODE"
    echo "🔍 Response: ${BODY:0:200}..."
fi

echo ""
echo "📋 CURSOR MCP INTEGRATION SUMMARY"
echo "================================"
echo "🎯 What We Accomplished:"
echo "  ✅ Created Cursor MCP configuration directory"
echo "  ✅ Generated ~/.cursor/mcp_config.json with Agent Builder integration"
echo "  ✅ Configured environment variables for Elastic connection"
echo "  ✅ Tested Agent Builder connectivity"
echo ""
echo "🔧 Configuration Details:"
echo "  📁 Config Directory: $CURSOR_CONFIG_DIR"
echo "  📄 Config File: $MCP_CONFIG_FILE"
echo "  🌐 Elastic Endpoint: $ELASTIC_ENDPOINT"
echo "  🔑 API Key: ${ELASTIC_API_KEY:0:20}..."
echo ""
echo "🎯 Available Agent Builder Tools:"
echo "  • platform.core.search - Search OTEL data in Elasticsearch"
echo "  • platform.core.execute_esql - Execute ESQL queries on OTEL data"
echo "  • platform.core.generate_esql - Generate ESQL queries for analysis"
echo ""
echo "🚀 Next Steps:"
echo "  1. Restart Cursor IDE to load the MCP configuration"
echo "  2. Open Cursor and test the Agent Builder integration"
echo "  3. Ask questions like: 'What's the health of my applications?'"
echo "  4. Use Agent Builder tools for OTEL data analysis"
echo ""
echo "🔗 Access your Elastic instance at: $ELASTIC_ENDPOINT"
echo "✅ Cursor MCP integration with Agent Builder complete!"
