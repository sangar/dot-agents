#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Programmatic Usage of Trello Tool

require 'json'
require_relative '../tool'

# Example 1: Basic Usage
puts "Example 1: Creating a Trello Tool instance"
puts "-" * 50

# Method 1: Using environment variables (recommended)
# Set these before running:
#   export TRELLO_API_KEY="your_key"
#   export TRELLO_API_TOKEN="your_token"

tool = TrelloTool.new

# Method 2: Passing credentials directly (not recommended for production)
# tool = TrelloTool.new('your_api_key', 'your_api_token')

puts "Tool initialized successfully"
puts ""

# Example 2: Executing Operations
puts "Example 2: Executing operations"
puts "-" * 50

# Get all boards
result = tool.execute('get_boards')

if result[:success]
  puts "Success! Retrieved #{result[:data].length} boards"
  result[:data].first(3).each do |board|
    puts "  - #{board['name']} (ID: #{board['id']})"
  end
else
  puts "Error: #{result[:error][:code]}"
  puts "Message: #{result[:error][:message]}"
  puts "Retryable: #{result[:error][:retryable]}"
end

puts ""

# Example 3: Handling Errors
puts "Example 3: Error handling"
puts "-" * 50

result = tool.execute('get_board', { 'board_id' => 'invalid_id_format!!!' })

if result[:success]
  puts "Success!"
else
  puts "Error Code: #{result[:error][:code]}"
  puts "Message: #{result[:error][:message]}"

  if result[:error][:retryable]
    puts "This error might succeed on retry"
  else
    puts "This error will not succeed on retry - check your input"
  end
end

puts ""

# Example 4: Creating a Card
puts "Example 4: Creating a card (requires valid list_id)"
puts "-" * 50

# Replace with actual list ID from your board
# list_id = "your_list_id_here"
#
# result = tool.execute('create_card', {
#   'list_id' => list_id,
#   'name' => 'New Task from Ruby',
#   'desc' => 'This card was created programmatically',
#   'due' => '2024-12-31T23:59:59.000Z',
#   'pos' => 'top'
# })
#
# if result[:success]
#   puts "Created card: #{result[:data]['name']}"
#   puts "Card ID: #{result[:data]['id']}"
#   puts "Card URL: #{result[:data]['shortUrl']}"
# else
#   puts "Failed to create card: #{result[:error][:message]}"
# end

puts "(Uncomment the code above with a valid list_id to create a card)"
puts ""

# Example 5: Working with Results
puts "Example 5: Working with results"
puts "-" * 50

result = tool.execute('get_boards')

if result[:success]
  # Access metadata
  puts "Execution time: #{result[:metadata][:execution_ms]}ms"
  puts "Timestamp: #{result[:metadata][:timestamp]}"

  # Access data
  puts "\nBoards:"
  result[:data].each_with_index do |board, i|
    puts "#{i + 1}. #{board['name']}"
    puts "   URL: #{board['url']}"
    puts "   Last activity: #{board['dateLastActivity']}"
    puts ""
  end
end

puts ""

# Example 6: Batch Operations
puts "Example 6: Batch operations pattern"
puts "-" * 50

# def get_all_cards_from_board(tool, board_id)
#   lists_result = tool.execute('get_lists', { 'board_id' => board_id })
#
#   return [] unless lists_result[:success]
#
#   all_cards = []
#   lists_result[:data].each do |list|
#     cards_result = tool.execute('get_cards', { 'list_id' => list['id'] })
#     if cards_result[:success]
#       all_cards.concat(cards_result[:data])
#     end
#   end
#
#   all_cards
# end

puts "(Uncomment and implement batch operations as needed)"
puts ""

puts "=" * 50
puts "Examples completed!"
puts "=" * 50
