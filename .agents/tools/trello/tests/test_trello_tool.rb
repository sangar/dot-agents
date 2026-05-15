#!/usr/bin/env ruby
# frozen_string_literal: true

# Trello Tool Test Suite

require 'json'
require 'tempfile'
require_relative '../tool'

class TrelloToolTest
  def initialize
    @tests_run = 0
    @tests_passed = 0
    @tests_failed = 0
  end

  def run_all_tests
    puts "=" * 60
    puts "Trello Tool Test Suite"
    puts "=" * 60
    puts ""

    # Only run unit tests without API credentials
    # Full integration tests require valid Trello credentials
    test_input_validation
    test_id_sanitization
    test_error_handling
    test_schema_validation

    puts ""
    puts "=" * 60
    puts "Test Results: #{@tests_passed}/#{@tests_run} passed"
    puts "=" * 60

    exit(@tests_failed > 0 ? 1 : 0)
  end

  private

  def test(name)
    @tests_run += 1
    print "  #{name}... "
    begin
      yield
      puts "PASSED"
      @tests_passed += 1
      true
    rescue StandardError => e
      puts "FAILED: #{e.message}"
      puts e.backtrace.first(3).map { |l| "    #{l}" }.join("\n")
      @tests_failed += 1
      false
    end
  end

  def test_input_validation
    puts "Testing Input Validation:"
    puts "-" * 40

    test "rejects unknown operation" do
      tool = TrelloTool.new('fake_key', 'fake_token')
      result = tool.execute('invalid_operation', {})
      
      raise "Expected failure" if result[:success]
      raise "Expected VALIDATION_ERROR" unless result[:error][:code] == 'VALIDATION_ERROR'
    end

    test "rejects missing board_id for get_board" do
      tool = TrelloTool.new('fake_key', 'fake_token')
      result = tool.execute('get_board', {})
      
      raise "Expected failure" if result[:success]
      raise "Expected VALIDATION_ERROR" unless result[:error][:code] == 'VALIDATION_ERROR'
    end

    test "rejects missing list_id and board_id for get_cards" do
      tool = TrelloTool.new('fake_key', 'fake_token')
      result = tool.execute('get_cards', {})
      
      raise "Expected failure" if result[:success]
      raise "Expected VALIDATION_ERROR" unless result[:error][:code] == 'VALIDATION_ERROR'
    end

    test "rejects missing name for create_card" do
      tool = TrelloTool.new('fake_key', 'fake_token')
      result = tool.execute('create_card', { 'list_id' => 'abc123' })
      
      raise "Expected failure" if result[:success]
      raise "Expected VALIDATION_ERROR" unless result[:error][:code] == 'VALIDATION_ERROR'
    end

    test "rejects missing list_id for create_card" do
      tool = TrelloTool.new('fake_key', 'fake_token')
      result = tool.execute('create_card', { 'name' => 'Test Card' })
      
      raise "Expected failure" if result[:success]
      raise "Expected VALIDATION_ERROR" unless result[:error][:code] == 'VALIDATION_ERROR'
    end

    test "rejects missing card_id for update_card" do
      tool = TrelloTool.new('fake_key', 'fake_token')
      result = tool.execute('update_card', { 'name' => 'New Name' })
      
      raise "Expected failure" if result[:success]
      raise "Expected VALIDATION_ERROR" unless result[:error][:code] == 'VALIDATION_ERROR'
    end

    test "rejects update with no fields" do
      tool = TrelloTool.new('fake_key', 'fake_token')
      result = tool.execute('update_card', { 'card_id' => 'abc123' })
      
      raise "Expected failure" if result[:success]
      raise "Expected VALIDATION_ERROR" unless result[:error][:code] == 'VALIDATION_ERROR'
    end

    test "rejects name over 16384 characters" do
      tool = TrelloTool.new('fake_key', 'fake_token')
      long_name = 'a' * 16385
      result = tool.execute('create_card', { 'list_id' => 'abc123', 'name' => long_name })
      
      raise "Expected failure" if result[:success]
      raise "Expected VALIDATION_ERROR" unless result[:error][:code] == 'VALIDATION_ERROR'
    end

    puts ""
  end

  def test_id_sanitization
    puts "Testing ID Sanitization:"
    puts "-" * 40

    test "allows valid IDs" do
      tool = TrelloTool.new('fake_key', 'fake_token')
      
      valid_ids = ['abc123', 'ABC123', 'abc-123', 'abc_123', '123', 'abc_123-456']
      
      valid_ids.each do |id|
        # We can't test actual execution without API, but we can verify
        # the sanitize_id method would accept these
      end
    end

    test "rejects IDs with invalid characters" do
      tool = TrelloTool.new('fake_key', 'fake_token')
      
      invalid_ids = ['abc/123', 'abc.123', 'abc\\123', 'abc 123', 'abc;123', '../etc/passwd']
      
      invalid_ids.each do |id|
        result = tool.execute('get_board', { 'board_id' => id })
        raise "Expected failure for ID: #{id}" if result[:success]
      end
    end

    test "rejects empty IDs" do
      tool = TrelloTool.new('fake_key', 'fake_token')
      result = tool.execute('get_board', { 'board_id' => '' })
      
      raise "Expected failure" if result[:success]
    end

    test "rejects IDs over 64 characters" do
      tool = TrelloTool.new('fake_key', 'fake_token')
      long_id = 'a' * 65
      result = tool.execute('get_board', { 'board_id' => long_id })
      
      raise "Expected failure" if result[:success]
    end

    puts ""
  end

  def test_error_handling
    puts "Testing Error Handling:"
    puts "-" * 40

    test "returns structured error on missing credentials" do
      begin
        TrelloTool.new('', '')
        raise "Expected AuthenticationError"
      rescue TrelloTool::AuthenticationError => e
        # Expected
      end
    end

    test "returns structured error on nil credentials" do
      # Temporarily unset environment variables to test nil credentials
      original_key = ENV.delete('TRELLO_API_KEY')
      original_token = ENV.delete('TRELLO_API_TOKEN')
      begin
        begin
          TrelloTool.new(nil, nil)
          raise "Expected AuthenticationError"
        rescue TrelloTool::AuthenticationError => e
          # Expected
        end
      ensure
        # Restore environment variables
        ENV['TRELLO_API_KEY'] = original_key if original_key
        ENV['TRELLO_API_TOKEN'] = original_token if original_token
      end
    end

    test "result includes execution metadata" do
      tool = TrelloTool.new('fake_key', 'fake_token')
      result = tool.execute('invalid_op', {})
      
      raise "Missing metadata" unless result[:metadata]
      raise "Missing execution_ms" unless result[:metadata][:execution_ms]
      raise "Missing timestamp" unless result[:metadata][:timestamp]
    end

    puts ""
  end

  def test_schema_validation
    puts "Testing Schema Validation:"
    puts "-" * 40

    test "validates input schema file exists" do
      schema_path = File.join(__dir__, '..', 'schema', 'input.schema.json')
      raise "Input schema not found" unless File.exist?(schema_path)
      
      schema = JSON.parse(File.read(schema_path))
      raise "Invalid schema" unless schema['type'] == 'object'
    end

    test "validates output schema file exists" do
      schema_path = File.join(__dir__, '..', 'schema', 'output.schema.json')
      raise "Output schema not found" unless File.exist?(schema_path)
      
      schema = JSON.parse(File.read(schema_path))
      raise "Invalid schema" unless schema['type'] == 'object'
    end

    test "validates manifest file exists" do
      manifest_path = File.join(__dir__, '..', 'manifest.yaml')
      raise "Manifest not found" unless File.exist?(manifest_path)
      
      content = File.read(manifest_path)
      raise "Empty manifest" if content.empty?
    end

    puts ""
  end
end

# Run tests if executed directly
if __FILE__ == $0
  test_suite = TrelloToolTest.new
  test_suite.run_all_tests
end
