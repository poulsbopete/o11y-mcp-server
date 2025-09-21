# 🔗 Cursor MCP Integration Guide

This guide shows you how to integrate Cursor with your Elastic OTEL MCP server for a complete MCP workflow.

## 📋 Prerequisites

- Cursor IDE installed
- Your Elastic OTEL MCP server running
- Elastic Serverless Observability endpoint
- Valid API key for Elastic

## 🔧 Step 1: Configure Cursor for MCP

### 1.1 Create Cursor MCP Configuration

Create or edit the Cursor MCP configuration file:

**On macOS:**
```bash
mkdir -p ~/.cursor
```

**On Windows:**
```bash
mkdir -p %APPDATA%\Cursor
```

**On Linux:**
```bash
mkdir -p ~/.config/cursor
```

### 1.2 Create MCP Configuration File

Create `~/.cursor/mcp_config.json` (or equivalent for your OS):

```json
{
  "mcpServers": {
    "elastic-otel": {
      "command": "python",
      "args": [
        "/opt/o11y-mcp-server/elastic-otel-mcp-server.py",
        "https://your-elastic-endpoint",
        "your-api-key"
      ],
      "env": {
        "PYTHONPATH": "/opt/o11y-mcp-server/venv/lib/python3.13/site-packages"
      }
    }
  }
}
```

### 1.3 Alternative: Use Virtual Environment

For better isolation, use the virtual environment:

```json
{
  "mcpServers": {
    "elastic-otel": {
      "command": "/opt/o11y-mcp-server/venv/bin/python",
      "args": [
        "/opt/o11y-mcp-server/elastic-otel-mcp-server.py",
        "https://your-elastic-endpoint",
        "your-api-key"
      ],
      "env": {}
    }
  }
}
```

## 🚀 Step 2: Start Your MCP Server

### 2.1 Start the Server
```bash
cd /opt/o11y-mcp-server
./run-mcp-server.sh <your-elastic-endpoint> <your-api-key>
```

### 2.2 Verify Server is Running
The server should show:
```
🚀 Starting Elastic OTEL MCP Server...
📊 Connecting to: https://your-elastic-endpoint
🎯 Available tools:
  - get_application_health
  - get_service_metrics
  - get_error_analysis
  - get_performance_issues
  - get_resource_utilization
  - get_trace_analysis
  - get_code_recommendations
```

## 🔗 Step 3: Configure Cursor

### 3.1 Open Cursor Settings
1. Open Cursor IDE
2. Go to Settings (Cmd/Ctrl + ,)
3. Search for "MCP" or "Model Context Protocol"

### 3.2 Add MCP Server Configuration
In Cursor settings, add your MCP server configuration:

```json
{
  "mcp": {
    "servers": {
      "elastic-otel": {
        "command": "python",
        "args": [
          "/opt/o11y-mcp-server/elastic-otel-mcp-server.py",
          "https://your-elastic-endpoint",
          "your-api-key"
        ],
        "env": {
          "PYTHONPATH": "/opt/o11y-mcp-server/venv/lib/python3.13/site-packages"
        }
      }
    }
  }
}
```

### 3.3 Restart Cursor
After adding the configuration, restart Cursor to load the MCP server.

## 🎯 Step 4: Use MCP Tools in Cursor

### 4.1 Available Tools in Cursor
Once configured, you can use these tools in Cursor:

- **`get_application_health`** - Get overall application health
- **`get_service_metrics`** - Get service-specific metrics
- **`get_error_analysis`** - Analyze errors and exceptions
- **`get_performance_issues`** - Identify performance bottlenecks
- **`get_resource_utilization`** - Monitor resource usage
- **`get_trace_analysis`** - Analyze distributed traces
- **`get_code_recommendations`** - Get optimization suggestions

### 4.2 Example Queries in Cursor

You can now ask Cursor questions like:

```
"What's the health of my applications?"
"Show me metrics for the payment service"
"What errors are happening in the last hour?"
"Find the slowest operations in my system"
"Analyze resource utilization across all services"
"Show me trace analysis for the checkout flow"
"What code optimizations do you recommend?"
```

## 🔄 Step 5: Complete MCP Workflow

### 5.1 Development Workflow
1. **Code Development**: Write code in Cursor
2. **Deploy to Elastic**: Send OTEL data to Elastic Serverless
3. **Monitor Health**: Use MCP tools to analyze application health
4. **Optimize**: Get recommendations and implement improvements
5. **Repeat**: Continuous monitoring and optimization

### 5.2 Example Workflow
```
1. Deploy application with OTEL instrumentation
2. Ask Cursor: "What's the health of my applications?"
3. Cursor uses MCP server to query Elastic data
4. Get insights about errors, performance, resources
5. Ask follow-up: "What optimizations do you recommend?"
6. Implement suggested improvements
7. Monitor results with: "Show me updated metrics"
```

## 🛠️ Troubleshooting

### Server Won't Start
- Check virtual environment: `source venv/bin/activate`
- Verify dependencies: `pip list | grep -E "(httpx|mcp)"`
- Test server manually: `python3 elastic-otel-mcp-server.py <endpoint> <key>`

### Cursor Can't Connect
- Verify MCP configuration in Cursor settings
- Check server is running and accessible
- Restart Cursor after configuration changes
- Check Cursor logs for MCP connection errors

### No Data in Queries
- Verify Elastic endpoint and API key
- Check if applications are sending OTEL data
- Ensure time range includes recent data
- Test Elastic connection independently

## 📚 Advanced Configuration

### Custom Environment Variables
```json
{
  "mcpServers": {
    "elastic-otel": {
      "command": "python",
      "args": [
        "/opt/o11y-mcp-server/elastic-otel-mcp-server.py",
        "https://your-elastic-endpoint",
        "your-api-key"
      ],
      "env": {
        "PYTHONPATH": "/opt/o11y-mcp-server/venv/lib/python3.13/site-packages",
        "ELASTIC_TIMEOUT": "30",
        "LOG_LEVEL": "INFO"
      }
    }
  }
}
```

### Multiple MCP Servers
```json
{
  "mcpServers": {
    "elastic-otel": {
      "command": "python",
      "args": ["/opt/o11y-mcp-server/elastic-otel-mcp-server.py", "endpoint1", "key1"]
    },
    "elastic-otel-staging": {
      "command": "python", 
      "args": ["/opt/o11y-mcp-server/elastic-otel-mcp-server.py", "endpoint2", "key2"]
    }
  }
}
```

## 🎉 Success!

You now have a complete MCP workflow:
- **Cursor IDE** for development
- **MCP Server** for Elastic data access
- **Elastic Serverless** for OTEL data storage
- **Real-time insights** for application health monitoring

This setup allows you to develop, monitor, and optimize your applications all within Cursor using the power of MCP!
