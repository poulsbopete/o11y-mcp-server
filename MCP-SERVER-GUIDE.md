# Elastic OTEL MCP Server Guide

This MCP (Model Context Protocol) server connects to Elastic Serverless Observability to provide real-time insights into your application health through OTEL metrics, traces, and logs.

## 🚀 Quick Start

### Option 1: Run with Demo Credentials
```bash
./run-mcp-server.sh demo
```

### Option 2: Run with Your Own Credentials
```bash
./run-mcp-server.sh <your-elastic-endpoint> <your-api-key>
```

### Option 3: Direct Python Execution
```bash
source venv/bin/activate
python3 elastic-otel-mcp-server.py <elastic-endpoint> <api-key>
```

## 🔧 Configuration

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

## 🎯 Available Tools

### 1. `get_application_health`
Get overall application health status from OTEL data
- **Parameters**: `time_range` (default: "15m")
- **Returns**: Health summary, error rates, performance metrics

### 2. `get_service_metrics`
Get metrics for specific services (CPU, memory, response time, error rate)
- **Parameters**: `service_name` (required), `time_range` (default: "15m")
- **Returns**: Service-specific metrics and performance data

### 3. `get_error_analysis`
Analyze errors and exceptions in your applications
- **Parameters**: `time_range` (default: "15m"), `severity` (default: "ERROR")
- **Returns**: Error patterns, stack traces, frequency analysis

### 4. `get_performance_issues`
Identify performance bottlenecks and slow operations
- **Parameters**: `time_range` (default: "15m"), `threshold_ms` (default: 1000)
- **Returns**: Slow queries, performance bottlenecks, optimization opportunities

### 5. `get_resource_utilization`
Monitor CPU, memory, and resource usage across services
- **Parameters**: `time_range` (default: "15m"), `resource_type` (default: "all")
- **Returns**: Resource usage patterns, capacity planning insights

### 6. `get_trace_analysis`
Analyze distributed traces for service dependencies and latency
- **Parameters**: `time_range` (default: "15m"), `operation_name` (optional)
- **Returns**: Trace analysis, service dependencies, latency breakdowns

### 7. `get_code_recommendations`
Get optimization recommendations based on observed patterns
- **Parameters**: `time_range` (default: "15m"), `focus_area` (default: "performance")
- **Returns**: Code optimization suggestions, best practices

## 📊 Data Sources

The server connects to Elastic Serverless Observability and queries:
- **Metrics**: `metrics-*` indices (CPU, memory, custom metrics)
- **Logs**: `logs-*` indices (application logs, errors, events)
- **Traces**: `traces-*` indices (distributed tracing data)

## 🔍 Example Usage

### Get Overall Health
```bash
# Query: "What's the health of my applications?"
# Tool: get_application_health
# Parameters: {"time_range": "1h"}
```

### Analyze Specific Service
```bash
# Query: "How is my payment service performing?"
# Tool: get_service_metrics
# Parameters: {"service_name": "payment-service", "time_range": "30m"}
```

### Find Performance Issues
```bash
# Query: "What are the slowest operations in my system?"
# Tool: get_performance_issues
# Parameters: {"time_range": "2h", "threshold_ms": 500}
```

### Analyze Errors
```bash
# Query: "What errors are occurring in my applications?"
# Tool: get_error_analysis
# Parameters: {"time_range": "1h", "severity": "ERROR"}
```

## 🛠️ Troubleshooting

### Connection Issues
- Verify your Elastic endpoint is accessible
- Check your API key has proper permissions
- Ensure your Elastic cluster has OTEL data

### No Data Found
- Check if your applications are sending OTEL data
- Verify the time range includes recent data
- Ensure proper data view configuration

### Performance Issues
- Use shorter time ranges for faster queries
- Check Elastic cluster performance
- Monitor server resource usage

## 📝 Logs

The server logs are available in the console output. Key log levels:
- `INFO`: General operation information
- `WARNING`: Non-critical issues
- `ERROR`: Connection or query failures

## 🔄 Integration

This MCP server can be integrated with:
- Claude Desktop (via MCP configuration)
- Other MCP-compatible applications
- Custom applications using the MCP protocol

## 📚 Next Steps

1. **Start the server**: `./run-mcp-server.sh demo`
2. **Test connection**: Verify logs show successful connection
3. **Query your data**: Use the available tools to analyze your OTEL data
4. **Integrate**: Add to your MCP client configuration
5. **Monitor**: Watch server logs for any issues
