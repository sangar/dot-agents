#!/bin/bash
# Example: Card Management Workflow

# Step 1: Create a card
# Replace LIST_ID with an actual list ID
echo "=== Creating a new card ==="
CARD_RESULT=$(echo '{
  "operation": "create_card",
  "params": {
    "list_id": "LIST_ID_HERE",
    "name": "New Task: Review Documentation",
    "desc": "Review the API documentation and provide feedback",
    "due": "2024-12-31T23:59:59.000Z"
  }
}' | ruby ../tool.rb)

echo "$CARD_RESULT" | jq '.'

# Extract card ID from response (requires jq)
CARD_ID=$(echo "$CARD_RESULT" | jq -r '.data.id // empty')

if [ -n "$CARD_ID" ]; then
  echo ""
  echo "=== Card created with ID: $CARD_ID ==="

  # Step 2: Add a comment
  echo ""
  echo "=== Adding comment to card ==="
  echo '{
    "operation": "add_comment",
    "params": {
      "card_id": "'$CARD_ID'",
      "text": "This is a priority task for this sprint."
    }
  }' | ruby ../tool.rb | jq '.'

  # Step 3: Update the card
  echo ""
  echo "=== Updating card name ==="
  echo '{
    "operation": "update_card",
    "params": {
      "card_id": "'$CARD_ID'",
      "name": "[URGENT] Review Documentation"
    }
  }' | ruby ../tool.rb | jq '.'

  # Step 4: Get card details
  echo ""
  echo "=== Getting updated card details ==="
  echo '{
    "operation": "get_card",
    "params": {
      "card_id": "'$CARD_ID'"
    }
  }' | ruby ../tool.rb | jq '.'

  # Step 5: Delete the card (requires confirmation in real usage)
  # echo ""
  # echo "=== Deleting card (DESTRUCTIVE) ==="
  # echo '{
  #   "operation": "delete_card",
  #   "params": {
  #     "card_id": "'$CARD_ID'"
  #   }
  # }' | ruby ../tool.rb | jq '.'
fi
