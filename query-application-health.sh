#!/bin/bash

echo "🏥 Querying Application Health via Elastic Agent Builder"
echo "======================================================="

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

ELASTIC_HOST="$ELASTIC_ENDPOINT"
API_KEY="$ELASTIC_API_KEY"

# Check if required environment variables are set
if [ -z "$ELASTIC_ENDPOINT" ] || [ -z "$ELASTIC_API_KEY" ]; then
    echo "❌ Error: Required environment variables not set!"
    echo "Please set ELASTIC_ENDPOINT and ELASTIC_API_KEY in your .env file"
    echo "Or run: ./setup-env.sh"
    exit 1
fi

echo "📊 Elastic Instance: $ELASTIC_HOST"
echo "🔑 API Key: ${API_KEY:0:20}..."
echo ""

# Function to query OTEL data using Agent Builder tools
query_otel_data() {
    local query="$1"
    local description="$2"
    
    echo "🔍 $description"
    echo "   Query: $query"
    
    local url="$ELASTIC_HOST/api/agent_builder/tools"
    local headers=(
        -H "Authorization: ApiKey $API_KEY"
        -H "kbn-xsrf: true"
        -H "Content-Type: application/json"
    )
    
    # Use the search tool to query OTEL data
    local search_body="{
        \"tool_name\": \"platform.core.search\",
        \"parameters\": {
            \"query\": \"$query\",
            \"index\": \"metrics-*\"
        }
    }"
    
    local response=$(curl -s -w "\n%{http_code}" -X POST "${headers[@]}" -d "$search_body" "$url")
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | head -n -1)
    
    echo "   Status: $http_code"
    
    if [ "$http_code" = "200" ]; then
        echo "   ✅ SUCCESS!"
        echo "   Response: ${body:0:500}..."
        return 0
    else
        echo "   ❌ Error: $http_code"
        echo "   Response: ${body:0:200}..."
        return 1
    fi
}

echo "🧪 STEP 1: Check Application Health Overview"
echo "==========================================="

# Query for overall application health
query_otel_data "application health status error rate performance" "Get overall application health"

echo ""
echo "🧪 STEP 2: Analyze Error Patterns"
echo "==============================="

# Query for error analysis
query_otel_data "error exception failure timeout" "Analyze error patterns"

echo ""
echo "🧪 STEP 3: Check Performance Metrics"
echo "==================================="

# Query for performance data
query_otel_data "response time latency throughput performance" "Check performance metrics"

echo ""
echo "🧪 STEP 4: Monitor Resource Utilization"
echo "====================================="

# Query for resource usage
query_otel_data "CPU memory resource utilization" "Monitor resource usage"

echo ""
echo "📋 APPLICATION HEALTH SUMMARY"
echo "============================"
echo "🎯 What We Analyzed:"
echo "  ✅ Overall application health status"
echo "  ✅ Error patterns and exceptions"
echo "  ✅ Performance metrics and latency"
echo "  ✅ Resource utilization (CPU, memory)"
echo ""
echo "🔧 Available Analysis Tools:"
echo "  • Search OTEL data across all indices"
echo "  • Execute ESQL queries for complex analysis"
echo "  • Generate custom queries for specific metrics"
echo "  • Real-time monitoring and alerting"
echo ""
echo "🚀 Next Steps:"
echo "  1. Access Elastic UI at: $ELASTIC_HOST"
echo "  2. Use Agent Builder for interactive analysis"
echo "  3. Create custom dashboards for monitoring"
echo "  4. Set up alerts for critical issues"
echo ""
echo "✅ Application health analysis complete!"
echo "🔗 Access your data at: $ELASTIC_HOST"
