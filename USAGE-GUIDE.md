# 🚀 Elastic OTEL MCP Server - Usage Guide

## ✅ Server Status: WORKING

The MCP server has been successfully fixed and is now ready to use! The initialization error has been resolved.

## 🎯 Quick Start

### Run with Demo Credentials
```bash
cd /opt/o11y-mcp-server
./run-mcp-server.sh demo
```

### Run with Your Own Credentials
```bash
./run-mcp-server.sh <your-elastic-endpoint> <your-api-key>
```

### Direct Python Execution
```bash
source venv/bin/activate
python3 elastic-otel-mcp-server.py <elastic-endpoint> <api-key>
```

## 🔧 What Was Fixed

The server had an initialization error with the `notification_options` parameter. This has been resolved by creating a proper notification options object with the required `tools_changed` attribute.

## 📊 Available Tools

Your MCP server provides **7 powerful tools** for analyzing application health:

### 1. `get_application_health`
- **Purpose**: Get overall application health status
- **Parameters**: `time_range` (default: "15m")
- **Use Case**: "What's the health of my applications?"

### 2. `get_service_metrics`
- **Purpose**: Get metrics for specific services (CPU, memory, response time, error rate)
- **Parameters**: `service_name` (required), `time_range` (default: "15m")
- **Use Case**: "How is my payment service performing?"

### 3. `get_error_analysis`
- **Purpose**: Analyze errors and exceptions in applications
- **Parameters**: `time_range` (default: "15m"), `severity` (default: "ERROR")
- **Use Case**: "What errors are occurring in my system?"

### 4. `get_performance_issues`
- **Purpose**: Identify performance bottlenecks and slow operations
- **Parameters**: `time_range` (default: "15m"), `threshold_ms` (default: 1000)
- **Use Case**: "What are the slowest operations?"

### 5. `get_resource_utilization`
- **Purpose**: Monitor CPU, memory, and resource usage
- **Parameters**: `time_range` (default: "15m"), `resource_type` (default: "all")
- **Use Case**: "Show me resource utilization across services"

### 6. `get_trace_analysis`
- **Purpose**: Analyze distributed traces for service dependencies
- **Parameters**: `time_range` (default: "15m"), `operation_name` (optional)
- **Use Case**: "Analyze service dependencies and latency"

### 7. `get_code_recommendations`
- **Purpose**: Get optimization recommendations based on patterns
- **Parameters**: `time_range` (default: "15m"), `focus_area` (default: "performance")
- **Use Case**: "What optimizations can I make?"

## 🔍 Data Sources

The server connects to Elastic Serverless Observability and queries:
- **Metrics**: `metrics-*` indices (CPU, memory, custom metrics)
- **Logs**: `logs-*` indices (application logs, errors, events)
- **Traces**: `traces-*` indices (distributed tracing data)

## 🛠️ Integration

### MCP Configuration
The server is configured in `mcp-config.json`:
```json
{
  "mcpServers": {
    "elastic-otel": {
      "command": "python",
      "args": ["/opt/o11y-mcp-server/elastic-otel-mcp-server.py", "https://your-endpoint", "your-api-key"],
      "env": {}
    }
  }
}
```

### Compatible Applications
- Claude Desktop (via MCP configuration)
- Other MCP-compatible applications
- Custom applications using the MCP protocol

## 📝 Example Queries

Once connected to an MCP client, you can ask questions like:

- "What's the overall health of my applications?"
- "Show me metrics for the payment service"
- "What errors are happening in the last hour?"
- "Find the slowest operations in my system"
- "Analyze resource utilization across all services"
- "Show me trace analysis for the checkout flow"
- "What code optimizations do you recommend?"

## 🔧 Troubleshooting

### Server Won't Start
- Ensure virtual environment is activated: `source venv/bin/activate`
- Check Python dependencies: `pip list | grep -E "(httpx|mcp)"`
- Verify Elastic endpoint and API key

### No Data Found
- Check if applications are sending OTEL data
- Verify time range includes recent data
- Ensure proper Elastic cluster configuration

### Connection Issues
- Verify Elastic endpoint accessibility
- Check API key permissions
- Monitor server logs for detailed error messages

## 📚 Files

- **Main Server**: `elastic-otel-mcp-server.py`
- **Configuration**: `mcp-config.json`
- **Dependencies**: `requirements.txt`
- **Startup Script**: `run-mcp-server.sh`
- **Virtual Environment**: `venv/`

## 🎉 Success!

Your Elastic OTEL MCP server is now fully functional and ready to provide real-time insights into your application health through OTEL metrics, traces, and logs!
