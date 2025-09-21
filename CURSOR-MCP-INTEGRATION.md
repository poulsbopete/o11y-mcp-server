# 🔗 Cursor MCP Integration Guide

This guide shows you how to integrate Cursor with Elastic Agent Builder for AI-powered application health monitoring.

## 📋 Prerequisites

- Cursor IDE installed
- Elastic Serverless Observability endpoint with Agent Builder enabled
- Valid API key for Elastic
- No local server required - direct connection to Elastic

## 🔧 Step 1: Configure Cursor for Agent Builder

### 1.1 Quick Setup

Use the automated setup script:

```bash
./setup-cursor-agent-builder.sh
```

This script will:
- Create the Cursor MCP configuration directory
- Generate `~/.cursor/mcp_config.json` with Agent Builder integration
- Set up environment variables for Elastic connection

### 1.2 Manual Setup

If you prefer manual configuration, create `~/.cursor/mcp_config.json`:

```json
{
  "mcpServers": {
    "elastic-agent-builder": {
      "command": "curl",
      "args": [
        "-X", "POST",
        "-H", "Authorization: ApiKey ${ELASTIC_API_KEY}",
        "-H", "kbn-xsrf: true",
        "-H", "Content-Type: application/json",
        "${ELASTIC_ENDPOINT}/api/agent_builder/tools"
      ],
      "env": {
        "ELASTIC_ENDPOINT": "${ELASTIC_ENDPOINT}",
        "ELASTIC_API_KEY": "${ELASTIC_API_KEY}"
      }
    }
  }
}
```

## 🚀 Step 2: Connect to Agent Builder

### 2.1 Test Agent Builder Connection
```bash
cd /opt/o11y-mcp-server
./connect-to-agent-builder.sh
```

### 2.2 Verify Agent Builder is Accessible
The connection should show:
```
🤖 Connecting to Elastic Agent Builder
📊 Connecting to: https://your-elastic-endpoint
✅ Agent Builder is accessible
🎯 Available tools:
  - platform.core.search
  - platform.core.execute_esql
  - platform.core.generate_esql
```

## 🔗 Step 3: Configure Cursor

### 3.1 Open Cursor Settings
1. Open Cursor IDE
2. Go to Settings (Cmd/Ctrl + ,)
3. Search for "MCP" or "Model Context Protocol"

### 3.2 Verify MCP Configuration
The setup script should have created `~/.cursor/mcp_config.json` with Agent Builder integration.

### 3.3 Restart Cursor
After configuration, restart Cursor to load the Agent Builder connection.

## 🎯 Step 4: Use Agent Builder Tools in Cursor

### 4.1 Available Tools in Cursor
Once configured, you can use these Agent Builder tools in Cursor:

- **`platform.core.search`** - Search OTEL data in Elasticsearch
- **`platform.core.execute_esql`** - Execute ESQL queries on OTEL data
- **`platform.core.generate_esql`** - Generate ESQL queries for analysis
- **Built-in Analysis** - Error patterns, performance metrics, resource utilization
- **Real-time Monitoring** - Application health, service dependencies, bottlenecks

### 4.2 Example Queries in Cursor

You can now ask Cursor questions like:

```
"What's the health of my applications?"
"Show me metrics for the payment service"
"What errors are happening in the last hour?"
"Find the slowest operations in my system"
"Analyze resource utilization across all services"
"Show me trace analysis for the checkout flow"
"Generate an ESQL query for error analysis"
```

## 🔄 Step 5: Complete Agent Builder Workflow

### 5.1 Development Workflow
1. **Code Development**: Write code in Cursor
2. **Deploy to Elastic**: Send OTEL data to Elastic Serverless
3. **Monitor Health**: Use Agent Builder tools to analyze application health
4. **Optimize**: Get AI-powered recommendations and implement improvements
5. **Repeat**: Continuous monitoring and optimization

### 5.2 Example Workflow
```
1. Deploy application with OTEL instrumentation
2. Ask Cursor: "What's the health of my applications?"
3. Cursor uses Agent Builder to query Elastic data
4. Get AI-powered insights about errors, performance, resources
5. Ask follow-up: "Generate an ESQL query for performance analysis"
6. Implement suggested improvements
7. Monitor results with: "Show me updated metrics using ESQL"
```

## 🛠️ Troubleshooting

### Agent Builder Connection Issues
- Test connection: `./connect-to-agent-builder.sh`
- Verify Elastic endpoint and API key
- Check if Agent Builder is enabled on your Elastic instance
- Ensure proper permissions for Agent Builder access

### Cursor Can't Connect
- Verify MCP configuration in Cursor settings
- Check Agent Builder is accessible
- Restart Cursor after configuration changes
- Check Cursor logs for MCP connection errors

### No Data in Queries
- Verify Elastic endpoint and API key
- Check if applications are sending OTEL data
- Ensure time range includes recent data
- Test Agent Builder connection independently

## 📚 Advanced Configuration

### Custom Environment Variables
```json
{
  "mcpServers": {
    "elastic-agent-builder": {
      "command": "curl",
      "args": [
        "-X", "POST",
        "-H", "Authorization: ApiKey ${ELASTIC_API_KEY}",
        "-H", "kbn-xsrf: true",
        "-H", "Content-Type: application/json",
        "${ELASTIC_ENDPOINT}/api/agent_builder/tools"
      ],
      "env": {
        "ELASTIC_ENDPOINT": "${ELASTIC_ENDPOINT}",
        "ELASTIC_API_KEY": "${ELASTIC_API_KEY}",
        "ELASTIC_TIMEOUT": "30",
        "LOG_LEVEL": "INFO"
      }
    }
  }
}
```

### Multiple Agent Builder Connections
```json
{
  "mcpServers": {
    "elastic-agent-builder-prod": {
      "command": "curl",
      "args": ["-X", "POST", "-H", "Authorization: ApiKey ${PROD_API_KEY}", "${PROD_ENDPOINT}/api/agent_builder/tools"]
    },
    "elastic-agent-builder-staging": {
      "command": "curl",
      "args": ["-X", "POST", "-H", "Authorization: ApiKey ${STAGING_API_KEY}", "${STAGING_ENDPOINT}/api/agent_builder/tools"]
    }
  }
}
```

## 🎉 Success!

You now have a complete Agent Builder workflow:
- **Cursor IDE** for development
- **Elastic Agent Builder** for AI-powered data analysis
- **Elastic Serverless** for OTEL data storage
- **Real-time insights** for application health monitoring

This setup allows you to develop, monitor, and optimize your applications all within Cursor using the power of Elastic Agent Builder!
