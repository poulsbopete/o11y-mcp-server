#!/bin/bash

echo "🔗 Setting up Elastic MCP Server as Cursor Endpoint"
echo "==================================================="

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

# Load environment variables
if [ -f .env ]; then
    echo "📄 Loading environment variables from .env file..."
    export $(cat .env | grep -v '^#' | xargs)
fi

# Get credentials from environment variables
if [ -z "$ELASTIC_ENDPOINT" ] || [ -z "$ELASTIC_API_KEY" ]; then
    echo "❌ Error: Required environment variables not set!"
    echo "Please set ELASTIC_ENDPOINT and ELASTIC_API_KEY in your .env file"
    echo "Or run: ./setup-env.sh"
    exit 1
fi

echo "📊 Elastic Endpoint: $ELASTIC_ENDPOINT"
echo "🔑 API Key: ${ELASTIC_API_KEY:0:20}..."

# Create MCP configuration
cat > "$CONFIG_FILE" << EOF
{
  "mcpServers": {
    "elastic-otel": {
      "command": "/opt/o11y-mcp-server/venv/bin/python",
      "args": [
        "/opt/o11y-mcp-server/elastic-otel-mcp-server.py"
      ],
      "env": {
        "ELASTIC_ENDPOINT": "$ELASTIC_ENDPOINT",
        "ELASTIC_API_KEY": "$ELASTIC_API_KEY"
      }
    }
  }
}
EOF

echo "✅ Cursor MCP configuration created!"
echo ""
echo "🔧 Configuration Details:"
echo "  • Server Name: elastic-otel"
echo "  • Command: Python MCP server"
echo "  • Environment: ELASTIC_ENDPOINT and ELASTIC_API_KEY set"
echo "  • Tools: 7 OTEL health analysis tools"
echo ""
echo "🚀 Next Steps:"
echo "1. Restart Cursor IDE"
echo "2. Start your MCP server: ./run-mcp-server.sh"
echo "3. In Cursor, ask questions like:"
echo "   - 'What's the health of my applications?'"
echo "   - 'Show me metrics for the payment service'"
echo "   - 'What errors are happening in the last hour?'"
echo "   - 'Find the slowest operations in my system'"
echo ""
echo "📚 Available MCP Tools in Cursor:"
echo "  • get_application_health - Overall health status"
echo "  • get_service_metrics - Service-specific metrics"
echo "  • get_error_analysis - Error and exception analysis"
echo "  • get_performance_issues - Performance bottleneck identification"
echo "  • get_resource_utilization - Resource usage monitoring"
echo "  • get_trace_analysis - Distributed trace analysis"
echo "  • get_code_recommendations - Optimization recommendations"
echo ""
echo "✅ Setup complete! Your Elastic MCP server is now configured as a Cursor endpoint."
