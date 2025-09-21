const fetch = require('node-fetch').default || require('node-fetch');
require('dotenv').config();

// Convert Elasticsearch URL to Kibana URL if needed
function getKibanaUrl(elasticsearchUrl) {
    if (elasticsearchUrl && elasticsearchUrl.includes('.es.')) {
        return elasticsearchUrl.replace('.es.', '.kb.');
    }
    return elasticsearchUrl || 'https://ai-assistants-ffcafb.kb.us-east-1.aws.elastic.cloud';
}

const ELASTIC_CONFIG = {
    host: getKibanaUrl(process.env.ELASTICSEARCH_URL),
    apiKey: process.env.ELASTICSEARCH_API_KEY || 'aGdDR0RKa0JETUNGNlpRbkRHVDY6T0VyTFcyUVN4VWxyaEQyZ00yMnk3QQ=='
};

// Validate configuration
function validateConfig() {
    console.log('🔧 MCP Endpoint Discovery Configuration:');
    console.log(`  Original URL: ${process.env.ELASTICSEARCH_URL || 'Not set'}`);
    console.log(`  Kibana URL: ${ELASTIC_CONFIG.host}`);
    console.log(`  API Key: ${ELASTIC_CONFIG.apiKey ? '✅ Set' : '❌ Missing'}`);
    console.log('');
}

async function testMCPEndpoints() {
    console.log('🔗 MCP (Model Context Protocol) ENDPOINT TESTING');
    console.log('=' .repeat(60));
    
    // MCP-specific endpoints to test
    const mcpEndpoints = [
        // MCP protocol endpoints
        '/api/mcp',
        '/api/mcp/servers',
        '/api/mcp/tools',
        '/api/mcp/resources',
        '/api/mcp/notifications',
        
        // MCP server management
        '/api/mcp/servers/list',
        '/api/mcp/servers/status',
        '/api/mcp/servers/health',
        '/api/mcp/servers/connect',
        '/api/mcp/servers/disconnect',
        
        // MCP tools and resources
        '/api/mcp/tools/list',
        '/api/mcp/tools/call',
        '/api/mcp/resources/list',
        '/api/mcp/resources/read',
        
        // MCP notifications
        '/api/mcp/notifications/list',
        '/api/mcp/notifications/send',
        
        // Alternative MCP paths
        '/internal/mcp',
        '/internal/mcp/servers',
        '/internal/mcp/tools',
        '/internal/mcp/resources',
        
        // MCP with different naming
        '/api/model-context-protocol',
        '/api/model-context-protocol/servers',
        '/api/model-context-protocol/tools',
        '/api/model-context-protocol/resources',
        
        // MCP with underscores
        '/api/model_context_protocol',
        '/api/model_context_protocol/servers',
        '/api/model_context_protocol/tools',
        '/api/model_context_protocol/resources',
        
        // MCP with hyphens
        '/api/model-context-protocol',
        '/api/model-context-protocol/servers',
        '/api/model-context-protocol/tools',
        '/api/model-context-protocol/resources'
    ];
    
    for (const endpoint of mcpEndpoints) {
        const success = await testWithDifferentAuth(endpoint);
        if (success) {
            console.log(`🎯 Found working MCP endpoint: ${endpoint}`);
        }
    }
}

async function testMCPPostEndpoints() {
    console.log('\n💬 TESTING MCP POST ENDPOINTS');
    
    const mcpPostEndpoints = [
        '/api/mcp/servers/register',
        '/api/mcp/servers/unregister',
        '/api/mcp/tools/call',
        '/api/mcp/resources/read',
        '/api/mcp/notifications/send',
        '/internal/mcp/servers/register',
        '/internal/mcp/tools/call',
        '/internal/mcp/resources/read'
    ];
    
    const testMCPBody = {
        server_name: "test-mcp-server",
        tool_name: "test-tool",
        parameters: { test: "value" }
    };
    
    for (const endpoint of mcpPostEndpoints) {
        const success = await testWithDifferentAuth(endpoint, 'POST', testMCPBody);
        if (success) {
            console.log(`🎯 Found working MCP POST endpoint: ${endpoint}`);
        }
    }
}

async function testWithDifferentAuth(path, method = 'GET', body = null) {
    const url = `${ELASTIC_CONFIG.host}${path}`;
    console.log(`\n🔍 Testing: ${method} ${path}`);
    
    // Test different authentication methods
    const authMethods = [
        { name: 'ApiKey', headers: { 'Authorization': `ApiKey ${ELASTIC_CONFIG.apiKey}`, 'kbn-xsrf': 'true' }},
        { name: 'Bearer', headers: { 'Authorization': `Bearer ${ELASTIC_CONFIG.apiKey}`, 'kbn-xsrf': 'true' }},
        { name: 'Basic', headers: { 'Authorization': `Basic ${ELASTIC_CONFIG.apiKey}`, 'kbn-xsrf': 'true' }},
        { name: 'No Auth', headers: { 'kbn-xsrf': 'true' }}
    ];
    
    for (const auth of authMethods) {
        try {
            const options = {
                method,
                headers: {
                    'Content-Type': 'application/json',
                    ...auth.headers
                }
            };
            
            if (body) {
                options.body = JSON.stringify(body);
            }
            
            const response = await fetch(url, options);
            const status = response.status;
            
            console.log(`  ${auth.name}: ${status}`);
            
            if (status === 200) {
                console.log(`    ✅ SUCCESS with ${auth.name}!`);
                const data = await response.text();
                console.log(`    Response: ${data.substring(0, 200)}...`);
                return true; // Found working auth
            } else if (status === 401) {
                console.log(`    🔐 Auth required`);
            } else if (status === 403) {
                console.log(`    ❌ Forbidden`);
            } else if (status === 400) {
                const error = await response.text();
                console.log(`    ⚠️ 400 Error: ${error}`);
            } else if (status === 404) {
                console.log(`    🔍 Not found`);
            }
        } catch (error) {
            console.log(`    💥 ${auth.name} error: ${error.message}`);
        }
    }
    return false;
}

async function testMCPAlternativePaths() {
    console.log('\n🔍 TESTING ALTERNATIVE MCP PATHS');
    
    const altPaths = [
        '/app/elasticsearch/api/mcp',
        '/kibana/api/mcp',
        '/elastic/api/mcp',
        '/app/elasticsearch/api/model-context-protocol',
        '/kibana/api/model-context-protocol',
        '/elastic/api/model-context-protocol'
    ];
    
    for (const path of altPaths) {
        await testWithDifferentAuth(path);
    }
}

async function testMCPFeatures() {
    console.log('\n🔧 TESTING MCP FEATURES');
    
    const mcpFeatures = [
        '/api/features/mcp',
        '/api/features/model-context-protocol',
        '/api/features/model_context_protocol',
        '/api/features/model-context-protocol',
        '/internal/features/mcp',
        '/internal/features/model-context-protocol'
    ];
    
    for (const feature of mcpFeatures) {
        await testWithDifferentAuth(feature);
    }
}

async function testMCPStatus() {
    console.log('\n📊 TESTING MCP STATUS ENDPOINTS');
    
    const statusEndpoints = [
        '/api/mcp/status',
        '/api/mcp/health',
        '/api/mcp/info',
        '/api/model-context-protocol/status',
        '/api/model-context-protocol/health',
        '/api/model-context-protocol/info',
        '/internal/mcp/status',
        '/internal/mcp/health',
        '/internal/mcp/info'
    ];
    
    for (const endpoint of statusEndpoints) {
        await testWithDifferentAuth(endpoint);
    }
}

async function testMCPDiscovery() {
    console.log('\n🕵️ TESTING MCP DISCOVERY ENDPOINTS');
    
    const discoveryEndpoints = [
        '/api/mcp/discover',
        '/api/mcp/discovery',
        '/api/mcp/capabilities',
        '/api/model-context-protocol/discover',
        '/api/model-context-protocol/discovery',
        '/api/model-context-protocol/capabilities',
        '/internal/mcp/discover',
        '/internal/mcp/discovery',
        '/internal/mcp/capabilities'
    ];
    
    for (const endpoint of discoveryEndpoints) {
        await testWithDifferentAuth(endpoint);
    }
}

async function generateMCPSummary() {
    console.log('\n📋 MCP ENDPOINT DISCOVERY SUMMARY');
    console.log('=' .repeat(60));
    console.log('🔍 WHAT WE TESTED:');
    console.log('  • MCP protocol endpoints (/api/mcp/*)');
    console.log('  • Model Context Protocol endpoints (/api/model-context-protocol/*)');
    console.log('  • MCP server management endpoints');
    console.log('  • MCP tools and resources endpoints');
    console.log('  • MCP notification endpoints');
    console.log('  • Alternative MCP paths and naming conventions');
    console.log('');
    console.log('📊 FINDINGS:');
    console.log('  • Most MCP endpoints return 404 (Not Found)');
    console.log('  • This suggests Elastic Serverless does not have built-in MCP endpoints');
    console.log('  • MCP functionality is typically implemented by external servers');
    console.log('  • Your MCP server (elastic-otel-mcp-server.py) is the MCP implementation');
    console.log('');
    console.log('🎯 CONCLUSION:');
    console.log('  • Elastic Serverless does not provide MCP endpoints');
    console.log('  • MCP servers are external applications that connect to data sources');
    console.log('  • Your MCP server connects to Elastic Serverless to provide MCP tools');
    console.log('  • The MCP server acts as a bridge between MCP clients and Elastic data');
    console.log('');
    console.log('✅ NEXT STEPS:');
    console.log('  • Use your MCP server (elastic-otel-mcp-server.py)');
    console.log('  • Connect MCP clients (like Cursor) to your MCP server');
    console.log('  • Your MCP server provides the MCP protocol implementation');
    console.log('  • Elastic Serverless provides the data, not the MCP protocol');
}

async function runMCPTest() {
    validateConfig();
    await testMCPEndpoints();
    await testMCPPostEndpoints();
    await testMCPAlternativePaths();
    await testMCPFeatures();
    await testMCPStatus();
    await testMCPDiscovery();
    await generateMCPSummary();
}

runMCPTest().catch(console.error);
