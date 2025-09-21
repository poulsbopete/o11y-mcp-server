#!/bin/bash

echo "🔗 Setting up Cursor MCP Integration"
echo "====================================="

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

# Copy the configuration
echo "📋 Copying MCP configuration..."
cp cursor-mcp-config.json "$CONFIG_FILE"

echo "✅ Cursor MCP configuration installed!"
echo ""
echo "🔧 Next steps:"
echo "1. Restart Cursor IDE"
echo "2. Start your MCP server: ./run-mcp-server.sh demo"
echo "3. In Cursor, ask questions like:"
echo "   - 'What's the health of my applications?'"
echo "   - 'Show me metrics for the payment service'"
echo "   - 'What errors are happening in the last hour?'"
echo ""
echo "📚 For detailed instructions, see: CURSOR-MCP-INTEGRATION.md"
