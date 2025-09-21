# 🚀 Elastic OTEL MCP Server

A Model Context Protocol (MCP) server that provides real-time insights into application health from Elastic Serverless Observability OTEL data.

## ✨ Features

- **7 Powerful Tools** for analyzing application health
- **Real-time Insights** from OTEL metrics, traces, and logs
- **Easy Integration** with Cursor IDE and other MCP clients
- **Comprehensive Monitoring** of services, errors, performance, and resources

## 🎯 Available Tools

- **`get_application_health`** - Overall application health status
- **`get_service_metrics`** - Service-specific metrics (CPU, memory, response time, error rate)
- **`get_error_analysis`** - Error and exception analysis
- **`get_performance_issues`** - Performance bottleneck identification
- **`get_resource_utilization`** - Resource usage monitoring
- **`get_trace_analysis`** - Distributed trace analysis
- **`get_code_recommendations`** - Optimization recommendations

## 🚀 Quick Start

### Prerequisites
- Python 3.8+
- Elastic Serverless Observability endpoint
- Valid API key for Elastic

### Installation

1. **Clone the repository**
   ```bash
   git clone git@github.com:poulsbopete/o11y-mcp-server.git
   cd o11y-mcp-server
   ```

2. **Set up virtual environment**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. **Run the server**
   ```bash
   # With demo credentials
   ./run-mcp-server.sh demo
   
   # With your own credentials
   ./run-mcp-server.sh <your-elastic-endpoint> <your-api-key>
   ```

## 🔗 Cursor Integration

### Quick Setup
```bash
./setup-cursor-mcp.sh
```

### Manual Setup
1. Copy `cursor-mcp-config.json` to your Cursor config directory
2. Restart Cursor IDE
3. Start your MCP server
4. Ask questions like "What's the health of my applications?"

## 📊 Data Sources

The server connects to Elastic Serverless Observability and queries:
- **Metrics**: `metrics-*` indices (CPU, memory, custom metrics)
- **Logs**: `logs-*` indices (application logs, errors, events)
- **Traces**: `traces-*` indices (distributed tracing data)

## 🛠️ Configuration

### MCP Configuration
```json
{
  "mcpServers": {
    "elastic-otel": {
      "command": "python",
      "args": ["/path/to/elastic-otel-mcp-server.py", "https://your-endpoint", "your-api-key"],
      "env": {}
    }
  }
}
```

### Environment Variables
- `ELASTIC_ENDPOINT` - Your Elastic Serverless endpoint
- `ELASTIC_API_KEY` - Your Elastic API key
- `LOG_LEVEL` - Logging level (default: INFO)

## 📝 Example Queries

Once connected to an MCP client, you can ask:

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
- Check dependencies: `pip list | grep -E "(httpx|mcp)"`
- Verify Elastic endpoint and API key

### No Data Found
- Check if applications are sending OTEL data
- Verify time range includes recent data
- Ensure proper Elastic cluster configuration

### Cursor Integration Issues
- Verify MCP configuration in Cursor settings
- Check server is running and accessible
- Restart Cursor after configuration changes

## 📚 Documentation

- **`USAGE-GUIDE.md`** - Complete usage guide
- **`CURSOR-MCP-INTEGRATION.md`** - Cursor integration guide
- **`MCP-SERVER-GUIDE.md`** - Detailed MCP server documentation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit changes: `git commit -am 'Add feature'`
4. Push to branch: `git push origin feature-name`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Built with [MCP (Model Context Protocol)](https://modelcontextprotocol.io/)
- Integrates with [Elastic Serverless Observability](https://www.elastic.co/cloud/serverless)
- Compatible with [Cursor IDE](https://cursor.sh/)

---

**Ready to monitor your application health with AI-powered insights!** 🎉