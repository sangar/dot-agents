#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

# Trello API Tool
# A secure, deterministic tool for interacting with the Trello API
class TrelloTool
  TRELLO_API_BASE = 'https://api.trello.com/1'

  # Error definitions
  class TrelloError < StandardError
    attr_reader :code, :retryable

    def initialize(message, code = 'UNKNOWN_ERROR', retryable = false)
      super(message)
      @code = code
      @retryable = retryable
    end
  end

  class AuthenticationError < TrelloError
    def initialize(message = 'Invalid API credentials')
      super(message, 'AUTHENTICATION_ERROR', false)
    end
  end

  class RateLimitError < TrelloError
    def initialize(message = 'Rate limit exceeded')
      super(message, 'RATE_LIMIT_ERROR', true)
    end
  end

  class NotFoundError < TrelloError
    def initialize(resource = 'Resource')
      super("#{resource} not found", 'NOT_FOUND', false)
    end
  end

  class ValidationError < TrelloError
    def initialize(message = 'Invalid input')
      super(message, 'VALIDATION_ERROR', false)
    end
  end

  def initialize(api_key = nil, api_token = nil)
    @api_key = api_key || ENV['TRELLO_API_KEY']
    @api_token = api_token || ENV['TRELLO_API_TOKEN']

    raise AuthenticationError, 'TRELLO_API_KEY not provided' if @api_key.nil? || @api_key.empty?
    raise AuthenticationError, 'TRELLO_API_TOKEN not provided' if @api_token.nil? || @api_token.empty?
  end

  def execute(operation, params = {})
    start_time = Time.now

    # Validate operation
    valid_operations = %w[
      get_boards get_board get_lists get_cards get_card
      create_card update_card move_card delete_card
      add_comment get_members search
    ]

    unless valid_operations.include?(operation)
      raise ValidationError, "Unknown operation: #{operation}. Valid operations: #{valid_operations.join(', ')}"
    end

    # Execute the operation
    result = send("operation_#{operation}", params)

    # Build structured response
    {
      success: true,
      operation: operation,
      data: result,
      metadata: {
        execution_ms: ((Time.now - start_time) * 1000).round(2),
        timestamp: Time.now.iso8601
      }
    }

  rescue TrelloError => e
    {
      success: false,
      operation: operation,
      error: {
        code: e.code,
        message: e.message,
        retryable: e.retryable
      },
      metadata: {
        execution_ms: ((Time.now - start_time) * 1000).round(2),
        timestamp: Time.now.iso8601
      }
    }
  rescue StandardError => e
    {
      success: false,
      operation: operation,
      error: {
        code: 'INTERNAL_ERROR',
        message: e.message,
        retryable: true
      },
      metadata: {
        execution_ms: ((Time.now - start_time) * 1000).round(2),
        timestamp: Time.now.iso8601
      }
    }
  end

  private

  # Authentication params
  def auth_params
    { key: @api_key, token: @api_token }
  end

  # HTTP request helper
  def make_request(method, endpoint, params = {}, body = nil)
    uri = URI.parse("#{TRELLO_API_BASE}#{endpoint}")

    # Add auth params to query
    query_params = auth_params.merge(params)
    uri.query = URI.encode_www_form(query_params)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 30

    case method.to_s.upcase
    when 'GET'
      request = Net::HTTP::Get.new(uri.request_uri)
    when 'POST'
      request = Net::HTTP::Post.new(uri.request_uri)
      request['Content-Type'] = 'application/json'
      request.body = body.to_json if body
    when 'PUT'
      request = Net::HTTP::Put.new(uri.request_uri)
      request['Content-Type'] = 'application/json'
      request.body = body.to_json if body
    when 'DELETE'
      request = Net::HTTP::Delete.new(uri.request_uri)
    else
      raise ValidationError, "Unsupported HTTP method: #{method}"
    end

    response = http.request(request)

    case response.code.to_i
    when 200..299
      JSON.parse(response.body)
    when 401
      raise AuthenticationError
    when 404
      raise NotFoundError
    when 429
      raise RateLimitError
    when 400
      raise ValidationError, JSON.parse(response.body)['message'] rescue ValidationError.new('Bad request')
    else
      raise TrelloError.new("HTTP #{response.code}: #{response.body}", 'HTTP_ERROR', response.code.to_i >= 500)
    end
  rescue JSON::ParserError => e
    raise TrelloError.new("Invalid JSON response: #{e.message}", 'PARSE_ERROR', true)
  end

  # Operations

  def operation_get_boards(_params = {})
    make_request('GET', '/members/me/boards', { fields: 'name,url,idOrganization,dateLastActivity' })
  end

  def operation_get_board(params)
    board_id = params['board_id'] || params[:board_id]
    raise ValidationError, 'board_id is required' if board_id.nil? || board_id.empty?

    make_request('GET', "/boards/#{sanitize_id(board_id)}", { fields: 'name,desc,url,idOrganization,dateLastActivity' })
  end

  def operation_get_lists(params)
    board_id = params['board_id'] || params[:board_id]
    raise ValidationError, 'board_id is required' if board_id.nil? || board_id.empty?

    make_request('GET', "/boards/#{sanitize_id(board_id)}/lists", { fields: 'name,pos,closed' })
  end

  def operation_get_cards(params)
    list_id = params['list_id'] || params[:list_id]
    board_id = params['board_id'] || params[:board_id]

    if list_id
      make_request('GET', "/lists/#{sanitize_id(list_id)}/cards", { fields: 'name,desc,due,pos,labels,url' })
    elsif board_id
      make_request('GET', "/boards/#{sanitize_id(board_id)}/cards", { fields: 'name,desc,due,pos,labels,url,idList' })
    else
      raise ValidationError, 'Either list_id or board_id is required'
    end
  end

  def operation_get_card(params)
    card_id = params['card_id'] || params[:card_id]
    raise ValidationError, 'card_id is required' if card_id.nil? || card_id.empty?

    make_request('GET', "/cards/#{sanitize_id(card_id)}", { fields: 'name,desc,due,pos,labels,url,idList,idBoard,shortUrl' })
  end

  def operation_create_card(params)
    list_id = params['list_id'] || params[:list_id]
    name = params['name'] || params[:name]

    raise ValidationError, 'list_id is required' if list_id.nil? || list_id.empty?
    raise ValidationError, 'name is required' if name.nil? || name.empty?
    raise ValidationError, 'name must be between 1 and 16384 characters' if name.length > 16384

    body = {
      idList: sanitize_id(list_id),
      name: name.to_s
    }

    body[:desc] = params['desc'] if params['desc']
    body[:due] = params['due'] if params['due']
    body[:pos] = params['pos'] if params['pos']

    make_request('POST', '/cards', {}, body)
  end

  def operation_update_card(params)
    card_id = params['card_id'] || params[:card_id]
    raise ValidationError, 'card_id is required' if card_id.nil? || card_id.empty?

    body = {}
    body[:name] = params['name'] if params['name']
    body[:desc] = params['desc'] if params['desc']
    body[:due] = params['due'] if params.key?('due')
    body[:pos] = params['pos'] if params['pos']
    body[:idList] = params['list_id'] if params['list_id']

    if body.empty?
      raise ValidationError, 'At least one field to update is required (name, desc, due, pos, list_id)'
    end

    make_request('PUT', "/cards/#{sanitize_id(card_id)}", {}, body)
  end

  def operation_move_card(params)
    card_id = params['card_id'] || params[:card_id]
    list_id = params['list_id'] || params[:list_id]

    raise ValidationError, 'card_id is required' if card_id.nil? || card_id.empty?
    raise ValidationError, 'list_id is required' if list_id.nil? || list_id.empty?

    body = { idList: sanitize_id(list_id) }
    body[:pos] = params['pos'] if params['pos']

    make_request('PUT', "/cards/#{sanitize_id(card_id)}", {}, body)
  end

  def operation_delete_card(params)
    card_id = params['card_id'] || params[:card_id]
    raise ValidationError, 'card_id is required' if card_id.nil? || card_id.empty?

    make_request('DELETE', "/cards/#{sanitize_id(card_id)}")
    { deleted: true, card_id: card_id }
  end

  def operation_add_comment(params)
    card_id = params['card_id'] || params[:card_id]
    text = params['text'] || params[:text]

    raise ValidationError, 'card_id is required' if card_id.nil? || card_id.empty?
    raise ValidationError, 'text is required' if text.nil? || text.empty?

    body = { text: text.to_s }
    make_request('POST', "/cards/#{sanitize_id(card_id)}/actions/comments", {}, body)
  end

  def operation_get_members(params)
    board_id = params['board_id'] || params[:board_id]
    card_id = params['card_id'] || params[:card_id]

    if board_id
      make_request('GET', "/boards/#{sanitize_id(board_id)}/members", { fields: 'fullName,username,avatarUrl' })
    elsif card_id
      make_request('GET', "/cards/#{sanitize_id(card_id)}/members", { fields: 'fullName,username,avatarUrl' })
    else
      raise ValidationError, 'Either board_id or card_id is required'
    end
  end

  def operation_search(params)
    query = params['query'] || params[:query]
    raise ValidationError, 'query is required' if query.nil? || query.empty?

    search_params = {
      query: query.to_s,
      modelTypes: params['model_types'] || 'cards,boards',
      partial: params['partial'] || false
    }

    make_request('GET', '/search', search_params)
  end

  # Sanitize IDs to prevent injection
  def sanitize_id(id)
    # Only allow alphanumeric characters, underscores, and hyphens
    sanitized = id.to_s.gsub(/[^a-zA-Z0-9_-]/, '')
    raise ValidationError, 'Invalid ID format' if sanitized.empty? || sanitized.length > 64
    sanitized
  end
end

# CLI entry point
if __FILE__ == $0
  # Read input from stdin
  input = JSON.parse(ARGF.read)

  operation = input['operation']
  params = input['params'] || {}

  tool = TrelloTool.new(
    input['api_key'],
    input['api_token']
  )

  result = tool.execute(operation, params)

  puts JSON.pretty_generate(result)

  exit(result[:success] || result['success'] ? 0 : 1)
end
