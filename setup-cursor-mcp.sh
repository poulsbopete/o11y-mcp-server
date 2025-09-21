#!/bin/bash

echo "🤖 Setting up Cursor MCP Integration with Elastic Agent Builder"
echo "==============================================================="

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

# Detect OS and set config path
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    CONFIG_DIR="$HOME/.cursor"
    CONFIG_FILE="$CONFIG_DIR/mcp_config.json"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    CONFIG_DIR="$HOME/.config/cursor"
    CONFIG_FILE="$CONFIG_DIR/mcp_config.json"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    # Windows
    CONFIG_DIR="$APPDATA/Cursor"
    CONFIG_FILE="$CONFIG_DIR/mcp_config.json"
else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
fi

echo "📁 Config directory: $CONFIG_DIR"
echo "📄 Config file: $CONFIG_FILE"

# Create config directory
mkdir -p "$CONFIG_DIR"

# Create Agent Builder MCP configuration
echo "📋 Creating Agent Builder MCP configuration..."
cat > "$CONFIG_FILE" << EOF
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

echo "✅ Cursor MCP configuration with Agent Builder installed!"
echo ""
echo "🔧 Next steps:"
echo "1. Restart Cursor IDE"
echo "2. Test Agent Builder connection: ./connect-to-agent-builder.sh"
echo "3. In Cursor, ask questions like:"
echo "   - 'What's the health of my applications?'"
echo "   - 'Show me metrics for the payment service'"
echo "   - 'What errors are happening in the last hour?'"
echo "   - 'Generate an ESQL query for performance analysis'"
echo ""
echo "🎯 Available Agent Builder Tools:"
echo "  • platform.core.search - Search OTEL data in Elasticsearch"
echo "  • platform.core.execute_esql - Execute ESQL queries on OTEL data"
echo "  • platform.core.generate_esql - Generate ESQL queries for analysis"
echo ""
echo "📚 For detailed instructions, see: CURSOR-MCP-INTEGRATION.md"
