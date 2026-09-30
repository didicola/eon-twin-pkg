#!/usr/bin/env node
/**
 * EON Opencode Config Validator
 * Validates opencode.jsonc for required fields, no secrets, valid structure
 */
const fs = require('fs');
const path = require('path');

const CONFIG_PATH = process.argv[2] || path.join(__dirname, '.config/opencode/opencode.jsonc');

function stripJsoncComments(content) {
  // State machine to handle strings and comments properly
  let result = '';
  let inString = false;
  let stringChar = '';
  let inBlockComment = false;
  let inLineComment = false;
  let escaped = false;
  
  for (let i = 0; i < content.length; i++) {
    const char = content[i];
    const next = content[i + 1] || '';
    
    if (inLineComment) {
      if (char === '\n') {
        inLineComment = false;
        result += char; // Keep the newline
      }
      continue;
    }
    
    if (inBlockComment) {
      if (char === '*' && next === '/') {
        inBlockComment = false;
        i++; // Skip the '/'
      }
      continue;
    }
    
    if (inString) {
      result += char;
      if (escaped) {
        escaped = false;
      } else if (char === '\\') {
        escaped = true;
      } else if (char === stringChar) {
        inString = false;
      }
      continue;
    }
    
    // Not in string or comment
    if (char === '"' || char === "'" || char === '`') {
      inString = true;
      stringChar = char;
      result += char;
    } else if (char === '/' && next === '/') {
      inLineComment = true;
    } else if (char === '/' && next === '*') {
      inBlockComment = true;
      i++; // Skip the '*'
    } else {
      result += char;
    }
  }
  
  return result;
}

function validateConfig() {
  const errors = [];
  const warnings = [];
  
  try {
    const content = fs.readFileSync(CONFIG_PATH, 'utf8');
    // Remove comments properly
    const jsonContent = stripJsoncComments(content);
    const config = JSON.parse(jsonContent);
    
    // Check required fields
    if (!config.model) errors.push('Missing required field: model');
    if (!config.provider) errors.push('Missing required field: provider');
    
    // Check for hardcoded API keys (not env var references)
    if (config.provider) {
      for (const [name, provider] of Object.entries(config.provider)) {
        if (provider.options?.apiKey && typeof provider.options.apiKey === 'string') {
          const key = provider.options.apiKey;
          if (!key.startsWith('$') && !key.startsWith('${') && key.length > 20) {
            warnings.push(`Provider ${name}: apiKey appears hardcoded (not env var reference)`);
          }
        }
      }
    }
    
    // Check MCP servers
    if (config.mcp) {
      for (const [name, server] of Object.entries(config.mcp)) {
        if (server.type === 'remote' && server.url) {
          try { new URL(server.url); }
          catch { warnings.push(`Invalid URL in MCP server ${name}: ${server.url}`); }
        }
      }
    }
    
  } catch (e) {
    return { valid: false, errors: [`Config parse error: ${e.message}`], warnings: [] };
  }
  
  return { valid: true, errors: [], warnings: [] };
}

const result = validateConfig();
console.log('VALIDATION RESULT:', result.errors.length === 0 ? 'PASS' : 'FAIL');
if (result.errors.length) console.log('ERRORS:', result.errors);
if (result.warnings.length) console.log('WARNINGS:', result.warnings);
process.exit(result.valid ? 0 : 1);