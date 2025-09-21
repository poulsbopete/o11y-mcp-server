# 🤖 Elastic Agent Builder Integration

Connect to Elastic Agent Builder for AI-powered application health monitoring using OTEL data from Elastic Serverless Observability.

## ✨ Features

- **AI-Powered Analysis** through Elastic Agent Builder
- **Real-time Insights** from OTEL metrics, traces, and logs
- **Built-in Tools** for comprehensive monitoring
- **Easy Integration** with Cursor IDE and other MCP clients
- **No Local Server Required** - direct connection to Elastic

## 🎯 Available Agent Builder Tools

- **`platform.core.search`** - Search OTEL data in Elasticsearch
- **`platform.core.execute_esql`** - Execute ESQL queries on OTEL data
- **`platform.core.generate_esql`** - Generate ESQL queries for analysis
- **Built-in Analysis** - Error patterns, performance metrics, resource utilization
- **Real-time Monitoring** - Application health, service dependencies, bottlenecks

## 🚀 Quick Start

### Prerequisites
- Elastic Serverless Observability endpoint with Agent Builder enabled
- Valid API key for Elastic
- Cursor IDE (optional, for MCP integration)

### Installation

1. **Clone the repository**
   ```bash
   git clone git@github.com:poulsbopete/o11y-mcp-server.git
   cd o11y-mcp-server
   ```

2. **Configure credentials**
   ```bash
   # Option 1: Use setup script (recommended)
   ./setup-env.sh
   # Then edit .env file with your credentials
   
   # Option 2: Set environment variables
   export ELASTIC_ENDPOINT=https://your-endpoint.kb.us-east-1.aws.elastic.cloud
   export ELASTIC_API_KEY=your-api-key
   ```

3. **Connect to Agent Builder**
   ```bash
   # Test Agent Builder connection
   ./connect-to-agent-builder.sh
   
   # Query application health
   ./query-application-health.sh
   ```

4. **Set up Cursor integration (optional)**
   ```bash
   # Create Cursor MCP configuration
   ./setup-cursor-agent-builder.sh
   ```

## 🔗 Cursor Integration

### Quick Setup
```bash
./setup-cursor-agent-builder.sh
```

### Manual Setup
1. Run the Cursor configuration script
2. Restart Cursor IDE
3. Connect to Elastic Agent Builder
4. Ask questions like "What's the health of my applications?"

## 📊 Data Sources

Agent Builder connects to Elastic Serverless Observability and analyzes:
- **Metrics**: `metrics-*` indices (CPU, memory, custom metrics)
- **Logs**: `logs-*` indices (application logs, errors, events)
- **Traces**: `traces-*` indices (distributed tracing data)

## 🛠️ Configuration

### Environment Variables
- `ELASTIC_ENDPOINT` - Your Elastic Serverless endpoint
- `ELASTIC_API_KEY` - Your Elastic API key
- `LOG_LEVEL` - Logging level (default: INFO)

### Cursor MCP Configuration
The setup script creates `~/.cursor/mcp_config.json` with Agent Builder integration.

## 📝 Example Queries

Once connected to Agent Builder, you can ask:

- "What's the overall health of my applications?"
- "Show me metrics for the payment service"
- "What errors are happening in the last hour?"
- "Find the slowest operations in my system"
- "Analyze resource utilization across all services"
- "Show me trace analysis for the checkout flow"
- "Generate an ESQL query for error analysis"

## 🔧 Troubleshooting

### Agent Builder Connection Issues
- Verify Elastic endpoint and API key
- Check if Agent Builder is enabled on your Elastic instance
- Test connection: `./connect-to-agent-builder.sh`

### No Data Found
- Check if applications are sending OTEL data
- Verify time range includes recent data
- Ensure proper Elastic cluster configuration

### Cursor Integration Issues
- Verify MCP configuration in Cursor settings
- Check Agent Builder is accessible
- Restart Cursor after configuration changes

## 📚 Documentation

- **`CURSOR-MCP-INTEGRATION.md`** - Cursor integration guide
- **`connect-to-agent-builder.sh`** - Agent Builder connection script
- **`query-application-health.sh`** - Application health analysis script

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit changes: `git commit -am 'Add feature'`
4. Push to branch: `git push origin feature-name`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Built with [Elastic Agent Builder](https://www.elastic.co/guide/en/elasticsearch/reference/current/agent-builder.html)
- Integrates with [Elastic Serverless Observability](https://www.elastic.co/cloud/serverless)
- Compatible with [Cursor IDE](https://cursor.sh/)

---

**Ready to monitor your application health with AI-powered insights through Elastic Agent Builder!** 🎉