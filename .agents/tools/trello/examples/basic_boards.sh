#!/bin/bash
# Example: Basic Board Operations

echo "=== Getting all boards ==="
echo '{"operation": "get_boards"}' | ruby ../tool.rb | jq '.'

echo ""
echo "=== Getting specific board (replace with your board ID) ==="
echo '{"operation": "get_board", "params": {"board_id": "BOARD_ID_HERE"}}' | ruby ../tool.rb | jq '.'

echo ""
echo "=== Getting lists on a board ==="
echo '{"operation": "get_lists", "params": {"board_id": "BOARD_ID_HERE"}}' | ruby ../tool.rb | jq '.'
