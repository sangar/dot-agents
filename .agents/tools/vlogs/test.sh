#!/bin/bash
# Quick test commands for vlogs tool

export VLOGS_SCRUB_KEY=${VLOGS_SCRUB_KEY:-"test-secret"}
VLOGS_DIR="/Users/gard/Developer/sh/dot-agents/.agents/tools/vlogs"
CONTEXT=${1:-"mock"}

echo "Testing vlogs tool with context: $CONTEXT"
echo ""

echo "1. Testing query (JSON):"
echo '{"command":"query","context":"'$CONTEXT'","query":"*","limit":5}' | ruby "$VLOGS_DIR/tool.rb" | head -20
echo ""

echo "2. Testing query (table):"
echo '{"command":"query","context":"'$CONTEXT'","query":"*","limit":5,"format":"table"}' | ruby "$VLOGS_DIR/tool.rb" | grep -o '"table_lines":\[[^]]*\]' | head -1
echo ""

echo "3. Testing stats:"
echo '{"command":"stats","context":"'$CONTEXT'","query":"stats count(*) by (level)","format":"table"}' | ruby "$VLOGS_DIR/tool.rb" | grep -o '"table_lines":\[[^]]*\]' | head -1
echo ""

echo "4. Testing fields:"
echo '{"command":"fields","context":"'$CONTEXT'","format":"table"}' | ruby "$VLOGS_DIR/tool.rb" | grep -o '"count":[0-9]*'
echo ""

echo "5. Testing values:"
echo '{"command":"values","context":"'$CONTEXT'","field":"level","format":"table"}' | ruby "$VLOGS_DIR/tool.rb" | grep -o '"count":[0-9]*'
echo ""

echo "6. Testing hits:"
echo '{"command":"hits","context":"'$CONTEXT'","field":"level","start":"1h"}' | ruby "$VLOGS_DIR/tool.rb" | grep -o '"total":[0-9]*'
echo ""

echo "All tests complete!"
