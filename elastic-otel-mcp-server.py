#!/usr/bin/env python3

"""
Elastic OTEL MCP Server
Provides real-time insights into application health from Elastic Serverless OTEL data
"""

import asyncio
import json
import logging
from datetime import datetime, timedelta
from typing import Any, Dict, List, Optional

import httpx
from mcp.server import Server
from mcp.server.models import InitializationOptions
from mcp.server.stdio import stdio_server
from mcp.types import (
    CallToolRequest,
    CallToolResult,
    ListToolsRequest,
    ListToolsResult,
    Tool,
)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ElasticOTELMCPServer:
    def __init__(self, elastic_endpoint: str, api_key: str):
        self.elastic_endpoint = elastic_endpoint
        self.api_key = api_key
        self.server = Server("elastic-otel-mcp")
        
        # Elastic data views
        self.data_views = {
            'metrics': 'metrics-*',
            'logs': 'logs-*', 
            'traces': 'traces-*'
        }
        
        self.setup_tools()
    
    def setup_tools(self):
        """Setup MCP tools for Elastic OTEL data"""
        
        @self.server.list_tools()
        async def list_tools() -> ListToolsResult:
            """List available tools for Elastic OTEL data"""
            return ListToolsResult(
                tools=[
                    Tool(
                        name="get_application_health",
                        description="Get overall application health status from OTEL data",
                        inputSchema={
                            "type": "object",
                            "properties": {
                                "time_range": {
                                    "type": "string",
                                    "description": "Time range for analysis (e.g., '15m', '1h', '1d')",
                                    "default": "15m"
                                }
                            }
                        }
                    ),
                    Tool(
                        name="get_service_metrics",
                        description="Get metrics for specific services (CPU, memory, response time, error rate)",
                        inputSchema={
                            "type": "object",
                            "properties": {
                                "service_name": {
                                    "type": "string",
                                    "description": "Name of the service to analyze"
                                },
                                "time_range": {
                                    "type": "string",
                                    "description": "Time range for analysis",
                                    "default": "15m"
                                }
                            },
                            "required": ["service_name"]
                        }
                    ),
                    Tool(
                        name="get_error_analysis",
                        description="Analyze errors and exceptions in your applications",
                        inputSchema={
                            "type": "object",
                            "properties": {
                                "time_range": {
                                    "type": "string",
                                    "description": "Time range for analysis",
                                    "default": "15m"
                                },
                                "severity": {
                                    "type": "string",
                                    "description": "Error severity level (ERROR, WARN, INFO)",
                                    "default": "ERROR"
                                }
                            }
                        }
                    ),
                    Tool(
                        name="get_performance_issues",
                        description="Identify performance bottlenecks and slow operations",
                        inputSchema={
                            "type": "object",
                            "properties": {
                                "time_range": {
                                    "type": "string",
                                    "description": "Time range for analysis",
                                    "default": "15m"
                                },
                                "threshold_ms": {
                                    "type": "number",
                                    "description": "Response time threshold in milliseconds",
                                    "default": 1000
                                }
                            }
                        }
                    ),
                    Tool(
                        name="get_resource_utilization",
                        description="Get CPU, memory, and resource utilization across hosts",
                        inputSchema={
                            "type": "object",
                            "properties": {
                                "time_range": {
                                    "type": "string",
                                    "description": "Time range for analysis",
                                    "default": "15m"
                                },
                                "resource_type": {
                                    "type": "string",
                                    "description": "Resource type (cpu, memory, disk, network)",
                                    "default": "cpu"
                                }
                            }
                        }
                    ),
                    Tool(
                        name="get_trace_analysis",
                        description="Analyze distributed traces for service dependencies and bottlenecks",
                        inputSchema={
                            "type": "object",
                            "properties": {
                                "time_range": {
                                    "type": "string",
                                    "description": "Time range for analysis",
                                    "default": "15m"
                                },
                                "service_name": {
                                    "type": "string",
                                    "description": "Optional service name to filter traces"
                                }
                            }
                        }
                    ),
                    Tool(
                        name="get_code_recommendations",
                        description="Get specific code recommendations based on OTEL data analysis",
                        inputSchema={
                            "type": "object",
                            "properties": {
                                "analysis_type": {
                                    "type": "string",
                                    "description": "Type of analysis (performance, errors, resources, traces)",
                                    "enum": ["performance", "errors", "resources", "traces"]
                                },
                                "time_range": {
                                    "type": "string",
                                    "description": "Time range for analysis",
                                    "default": "15m"
                                }
                            },
                            "required": ["analysis_type"]
                        }
                    )
                ]
            )
        
        @self.server.call_tool()
        async def call_tool(name: str, arguments: Dict[str, Any]) -> CallToolResult:
            """Handle tool calls for Elastic OTEL data"""
            try:
                if name == "get_application_health":
                    result = await self.get_application_health(arguments.get("time_range", "15m"))
                elif name == "get_service_metrics":
                    result = await self.get_service_metrics(
                        arguments["service_name"], 
                        arguments.get("time_range", "15m")
                    )
                elif name == "get_error_analysis":
                    result = await self.get_error_analysis(
                        arguments.get("time_range", "15m"),
                        arguments.get("severity", "ERROR")
                    )
                elif name == "get_performance_issues":
                    result = await self.get_performance_issues(
                        arguments.get("time_range", "15m"),
                        arguments.get("threshold_ms", 1000)
                    )
                elif name == "get_resource_utilization":
                    result = await self.get_resource_utilization(
                        arguments.get("time_range", "15m"),
                        arguments.get("resource_type", "cpu")
                    )
                elif name == "get_trace_analysis":
                    result = await self.get_trace_analysis(
                        arguments.get("time_range", "15m"),
                        arguments.get("service_name")
                    )
                elif name == "get_code_recommendations":
                    result = await self.get_code_recommendations(
                        arguments["analysis_type"],
                        arguments.get("time_range", "15m")
                    )
                else:
                    result = {"error": f"Unknown tool: {name}"}
                
                return CallToolResult(content=[{"type": "text", "text": json.dumps(result, indent=2)}])
                
            except Exception as e:
                logger.error(f"Error calling tool {name}: {e}")
                return CallToolResult(content=[{"type": "text", "text": f"Error: {str(e)}"}])
    
    async def execute_esql_query(self, query: str, data_view: str) -> Dict[str, Any]:
        """Execute ESQL query against Elastic"""
        headers = {
            "Authorization": f"ApiKey {self.api_key}",
            "Content-Type": "application/json",
            "kbn-xsrf": "true"
        }
        
        async with httpx.AsyncClient() as client:
            try:
                response = await client.post(
                    f"{self.elastic_endpoint}/_query",
                    headers=headers,
                    json={
                        "query": query,
                        "index": data_view
                    }
                )
                response.raise_for_status()
                return response.json()
            except Exception as e:
                logger.error(f"ESQL query failed: {e}")
                return {"error": str(e)}
    
    async def get_application_health(self, time_range: str) -> Dict[str, Any]:
        """Get overall application health status"""
        health_data = {
            "timestamp": datetime.now().isoformat(),
            "time_range": time_range,
            "overall_status": "unknown",
            "services": {},
            "alerts": []
        }
        
        # Get error rates
        error_query = f"""
        FROM traces-*
        | WHERE @timestamp >= NOW() - {time_range}
        | STATS error_rate = AVG(CASE WHEN transaction.result = "error" THEN 1 ELSE 0 END) BY service.name
        | SORT error_rate DESC
        """
        
        error_data = await self.execute_esql_query(error_query, self.data_views['traces'])
        
        # Get response times
        response_query = f"""
        FROM traces-*
        | WHERE @timestamp >= NOW() - {time_range}
        | STATS avg_response_time = AVG(transaction.duration.us) BY service.name
        | SORT avg_response_time DESC
        """
        
        response_data = await self.execute_esql_query(response_query, self.data_views['traces'])
        
        # Analyze health
        if error_data.get("rows"):
            for row in error_data["rows"]:
                service = row[0]
                error_rate = row[1]
                health_data["services"][service] = {
                    "error_rate": error_rate,
                    "status": "healthy" if error_rate < 0.05 else "degraded" if error_rate < 0.2 else "critical"
                }
                
                if error_rate > 0.2:
                    health_data["alerts"].append(f"High error rate for {service}: {error_rate:.2%}")
        
        return health_data
    
    async def get_service_metrics(self, service_name: str, time_range: str) -> Dict[str, Any]:
        """Get detailed metrics for a specific service"""
        metrics = {
            "service": service_name,
            "timestamp": datetime.now().isoformat(),
            "time_range": time_range,
            "metrics": {}
        }
        
        # Get transaction metrics
        transaction_query = f"""
        FROM traces-*
        | WHERE @timestamp >= NOW() - {time_range} AND service.name = "{service_name}"
        | STATS 
            transaction_count = COUNT(*),
            error_count = COUNT(CASE WHEN transaction.result = "error" THEN 1 END),
            avg_duration = AVG(transaction.duration.us),
            p95_duration = PERCENTILE(transaction.duration.us, 95),
            p99_duration = PERCENTILE(transaction.duration.us, 99)
        """
        
        transaction_data = await self.execute_esql_query(transaction_query, self.data_views['traces'])
        
        if transaction_data.get("rows"):
            row = transaction_data["rows"][0]
            metrics["metrics"]["transactions"] = {
                "count": row[0],
                "errors": row[1],
                "error_rate": row[1] / row[0] if row[0] > 0 else 0,
                "avg_duration_ms": row[2] / 1000 if row[2] else 0,
                "p95_duration_ms": row[3] / 1000 if row[3] else 0,
                "p99_duration_ms": row[4] / 1000 if row[4] else 0
            }
        
        # Get resource metrics
        resource_query = f"""
        FROM metrics-*
        | WHERE @timestamp >= NOW() - {time_range} AND service.name = "{service_name}"
        | STATS 
            avg_cpu = AVG(system.cpu.utilization),
            avg_memory = AVG(system.memory.utilization)
        """
        
        resource_data = await self.execute_esql_query(resource_query, self.data_views['metrics'])
        
        if resource_data.get("rows"):
            row = resource_data["rows"][0]
            metrics["metrics"]["resources"] = {
                "avg_cpu_percent": row[0] * 100 if row[0] else 0,
                "avg_memory_percent": row[1] * 100 if row[1] else 0
            }
        
        return metrics
    
    async def get_error_analysis(self, time_range: str, severity: str = "ERROR") -> Dict[str, Any]:
        """Analyze errors and exceptions"""
        error_analysis = {
            "timestamp": datetime.now().isoformat(),
            "time_range": time_range,
            "severity": severity,
            "errors": []
        }
        
        # Get error logs
        error_query = f"""
        FROM logs-*
        | WHERE @timestamp >= NOW() - {time_range} AND log.level = "{severity}"
        | STATS error_count = COUNT(*) BY service.name, message
        | SORT error_count DESC
        | LIMIT 20
        """
        
        error_data = await self.execute_esql_query(error_query, self.data_views['logs'])
        
        if error_data.get("rows"):
            for row in error_data["rows"]:
                error_analysis["errors"].append({
                    "service": row[0],
                    "message": row[1],
                    "count": row[2]
                })
        
        return error_analysis
    
    async def get_performance_issues(self, time_range: str, threshold_ms: int = 1000) -> Dict[str, Any]:
        """Identify performance bottlenecks"""
        performance_issues = {
            "timestamp": datetime.now().isoformat(),
            "time_range": time_range,
            "threshold_ms": threshold_ms,
            "slow_operations": []
        }
        
        # Get slow operations
        slow_query = f"""
        FROM traces-*
        | WHERE @timestamp >= NOW() - {time_range} AND transaction.duration.us > {threshold_ms * 1000}
        | STATS 
            count = COUNT(*),
            avg_duration = AVG(transaction.duration.us),
            max_duration = MAX(transaction.duration.us)
        BY service.name, transaction.name
        | SORT avg_duration DESC
        | LIMIT 20
        """
        
        slow_data = await self.execute_esql_query(slow_query, self.data_views['traces'])
        
        if slow_data.get("rows"):
            for row in slow_data["rows"]:
                performance_issues["slow_operations"].append({
                    "service": row[0],
                    "operation": row[1],
                    "count": row[2],
                    "avg_duration_ms": row[3] / 1000 if row[3] else 0,
                    "max_duration_ms": row[4] / 1000 if row[4] else 0
                })
        
        return performance_issues
    
    async def get_resource_utilization(self, time_range: str, resource_type: str = "cpu") -> Dict[str, Any]:
        """Get resource utilization metrics"""
        resource_data = {
            "timestamp": datetime.now().isoformat(),
            "time_range": time_range,
            "resource_type": resource_type,
            "utilization": {}
        }
        
        # Get resource metrics
        if resource_type == "cpu":
            query = f"""
            FROM metrics-*
            | WHERE @timestamp >= NOW() - {time_range}
            | STATS avg_cpu = AVG(system.cpu.utilization) BY host.name
            | SORT avg_cpu DESC
            """
        elif resource_type == "memory":
            query = f"""
            FROM metrics-*
            | WHERE @timestamp >= NOW() - {time_range}
            | STATS avg_memory = AVG(system.memory.utilization) BY host.name
            | SORT avg_memory DESC
            """
        else:
            query = f"""
            FROM metrics-*
            | WHERE @timestamp >= NOW() - {time_range}
            | STATS avg_utilization = AVG(system.{resource_type}.utilization) BY host.name
            | SORT avg_utilization DESC
            """
        
        utilization_data = await self.execute_esql_query(query, self.data_views['metrics'])
        
        if utilization_data.get("rows"):
            for row in utilization_data["rows"]:
                host = row[0]
                utilization = row[1]
                resource_data["utilization"][host] = {
                    "value": utilization * 100 if utilization else 0,
                    "unit": "percent",
                    "status": "critical" if utilization > 0.9 else "warning" if utilization > 0.8 else "healthy"
                }
        
        return resource_data
    
    async def get_trace_analysis(self, time_range: str, service_name: Optional[str] = None) -> Dict[str, Any]:
        """Analyze distributed traces"""
        trace_analysis = {
            "timestamp": datetime.now().isoformat(),
            "time_range": time_range,
            "service_filter": service_name,
            "service_dependencies": {},
            "bottlenecks": []
        }
        
        # Get service dependencies
        dependency_query = f"""
        FROM traces-*
        | WHERE @timestamp >= NOW() - {time_range}
        {f'AND service.name = "{service_name}"' if service_name else ''}
        | STATS call_count = COUNT(*) BY service.name, service.target.name
        | WHERE service.target.name IS NOT NULL
        | SORT call_count DESC
        """
        
        dependency_data = await self.execute_esql_query(dependency_query, self.data_views['traces'])
        
        if dependency_data.get("rows"):
            for row in dependency_data["rows"]:
                source_service = row[0]
                target_service = row[1]
                call_count = row[2]
                
                if source_service not in trace_analysis["service_dependencies"]:
                    trace_analysis["service_dependencies"][source_service] = []
                
                trace_analysis["service_dependencies"][source_service].append({
                    "target": target_service,
                    "call_count": call_count
                })
        
        return trace_analysis
    
    async def get_code_recommendations(self, analysis_type: str, time_range: str) -> Dict[str, Any]:
        """Get specific code recommendations based on OTEL data"""
        recommendations = {
            "timestamp": datetime.now().isoformat(),
            "analysis_type": analysis_type,
            "time_range": time_range,
            "recommendations": []
        }
        
        if analysis_type == "performance":
            # Get performance recommendations
            performance_data = await self.get_performance_issues(time_range, 500)
            for slow_op in performance_data.get("slow_operations", []):
                recommendations["recommendations"].append({
                    "type": "performance",
                    "priority": "high" if slow_op["avg_duration_ms"] > 2000 else "medium",
                    "service": slow_op["service"],
                    "operation": slow_op["operation"],
                    "issue": f"Slow operation: {slow_op['operation']} averaging {slow_op['avg_duration_ms']:.0f}ms",
                    "suggestion": "Consider optimizing this operation, adding caching, or using async processing"
                })
        
        elif analysis_type == "errors":
            # Get error recommendations
            error_data = await self.get_error_analysis(time_range)
            for error in error_data.get("errors", [])[:5]:
                recommendations["recommendations"].append({
                    "type": "error",
                    "priority": "high",
                    "service": error["service"],
                    "issue": f"Frequent error: {error['message']} ({error['count']} occurrences)",
                    "suggestion": "Add proper error handling, validation, or fix the root cause"
                })
        
        elif analysis_type == "resources":
            # Get resource recommendations
            cpu_data = await self.get_resource_utilization(time_range, "cpu")
            memory_data = await self.get_resource_utilization(time_range, "memory")
            
            for host, metrics in cpu_data.get("utilization", {}).items():
                if metrics["status"] == "critical":
                    recommendations["recommendations"].append({
                        "type": "resource",
                        "priority": "high",
                        "host": host,
                        "resource": "CPU",
                        "issue": f"High CPU usage: {metrics['value']:.1f}%",
                        "suggestion": "Consider scaling horizontally, optimizing CPU-intensive operations, or upgrading resources"
                    })
            
            for host, metrics in memory_data.get("utilization", {}).items():
                if metrics["status"] == "critical":
                    recommendations["recommendations"].append({
                        "type": "resource",
                        "priority": "high",
                        "host": host,
                        "resource": "Memory",
                        "issue": f"High memory usage: {metrics['value']:.1f}%",
                        "suggestion": "Check for memory leaks, optimize memory usage, or increase available memory"
                    })
        
        return recommendations
    
    async def run(self):
        """Run the MCP server"""
        async with stdio_server() as (read_stream, write_stream):
            await self.server.run(
                read_stream,
                write_stream,
                InitializationOptions(
                    server_name="elastic-otel-mcp",
                    server_version="1.0.0",
                    capabilities=self.server.get_capabilities(
                        notification_options=type('NotificationOptions', (), {'tools_changed': False})(),
                        experimental_capabilities={}
                    ),
                ),
            )

def main():
    """Main entry point"""
    import sys
    import os
    
    # Try to get credentials from environment variables first
    elastic_endpoint = os.getenv('ELASTIC_ENDPOINT')
    api_key = os.getenv('ELASTIC_API_KEY')
    
    # If not in environment, try command line arguments
    if not elastic_endpoint or not api_key:
        if len(sys.argv) != 3:
            print("Usage: python elastic-otel-mcp-server.py <elastic-endpoint> <api-key>")
            print("Or set environment variables: ELASTIC_ENDPOINT and ELASTIC_API_KEY")
            print("Example: python elastic-otel-mcp-server.py https://your-endpoint.kb.us-east-1.aws.elastic.cloud your-api-key")
            sys.exit(1)
        
        elastic_endpoint = sys.argv[1]
        api_key = sys.argv[2]
    
    server = ElasticOTELMCPServer(elastic_endpoint, api_key)
    
    print("🚀 Starting Elastic OTEL MCP Server...")
    print(f"📊 Connecting to: {elastic_endpoint}")
    print("🎯 Available tools:")
    print("  - get_application_health")
    print("  - get_service_metrics")
    print("  - get_error_analysis")
    print("  - get_performance_issues")
    print("  - get_resource_utilization")
    print("  - get_trace_analysis")
    print("  - get_code_recommendations")
    
    asyncio.run(server.run())

if __name__ == "__main__":
    main()
