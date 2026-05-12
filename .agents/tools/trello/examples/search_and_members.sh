#!/bin/bash
# Example: Search Operations

echo "=== Searching for cards containing 'bug' ==="
echo '{
  "operation": "search",
  "params": {
    "query": "bug",
    "model_types": "cards"
  }
}' | ruby ../tool.rb | jq '.'

echo ""
echo "=== Searching across cards and boards ==="
echo '{
  "operation": "search",
  "params": {
    "query": "project",
    "model_types": "cards,boards",
    "partial": true
  }
}' | ruby ../tool.rb | jq '.'

echo ""
echo "=== Getting members of a board ==="
echo '{
  "operation": "get_members",
  "params": {
    "board_id": "BOARD_ID_HERE"
  }
}' | ruby ../tool.rb | jq '.'
