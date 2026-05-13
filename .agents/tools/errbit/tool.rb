# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'
require 'openssl'

# Errbit API Client Tool
# Interacts with errbit instance at https://errbit.dialogapi.no
# Note: Each app in Errbit has its own API key. Operations require the API key
# of the app that owns the resource being accessed.
class ErrbitClient
  DEFAULT_BASE_URL = 'https://errbit.dialogapi.no'

  # Initialize the client with authentication credentials
  # @param api_key [String] The app's API key (stored centrally for all requests)
  # @param base_url [String] Optional base URL override
  def initialize(api_key:, base_url: nil)
    @api_key = api_key
    @base_url = (base_url || DEFAULT_BASE_URL).chomp('/')
  end

  # List all problems for the app
  # @param start_date [String] Optional start date filter (ISO 8601 format)
  # @param end_date [String] Optional end date filter (ISO 8601 format)
  # @return [Hash] Problems list response
  def list_problems(start_date: nil, end_date: nil)
    params = build_params
    params[:start_date] = start_date if start_date
    params[:end_date] = end_date if end_date

    get("/api/v1/problems", params)
  end

  # Get a specific problem by ID
  # @param problem_id [String] The problem ID
  # @return [Hash] Problem details
  def get_problem(problem_id:)
    get("/api/v1/problems/#{problem_id}", build_params)
  end

  # List all notices for the app
  # @param start_date [String] Optional start date filter (ISO 8601 format)
  # @param end_date [String] Optional end date filter (ISO 8601 format)
  # @return [Hash] Notices list response
  def list_notices(start_date: nil, end_date: nil)
    params = build_params
    params[:start_date] = start_date if start_date
    params[:end_date] = end_date if end_date

    get("/api/v1/notices", params)
  end

  # Get stats for the app
  # @return [Hash] App statistics
  def get_stats
    get("/api/v1/stats/app", build_params)
  end

  # List comments for a problem
  # @param problem_id [String] The problem ID
  # @return [Hash] Comments list
  def list_comments(problem_id:)
    get("/api/v1/problems/#{problem_id}/comments", build_params)
  end

  # Create a comment on a problem
  # @param problem_id [String] The problem ID
  # @param body [String] The comment body
  # @return [Hash] Created comment
  def create_comment(problem_id:, body:)
    payload = { comment: { body: body } }
    post("/api/v1/problems/#{problem_id}/comments", build_params, payload)
  end

  private

  # Build params hash with authentication token
  # @return [Hash] Params with auth_token included
  def build_params
    { auth_token: @api_key }
  end

  def get(path, params = {})
    uri = build_uri(path, params)
    request = Net::HTTP::Get.new(uri)
    request['Accept'] = 'application/json'
    request['Content-Type'] = 'application/json'
    execute_request(request, uri)
  end

  def post(path, params = {}, payload = {})
    uri = build_uri(path, params)
    request = Net::HTTP::Post.new(uri)
    request['Accept'] = 'application/json'
    request['Content-Type'] = 'application/json'
    request.body = payload.to_json
    execute_request(request, uri)
  end

  def build_uri(path, params)
    uri = URI.parse("#{@base_url}#{path}.json")
    uri.query = URI.encode_www_form(params) unless params.empty?
    uri
  end

  def execute_request(request, uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.open_timeout = 10
    http.read_timeout = 30

    response = http.request(request)

    # NOTE: index endpoints are buggy for now https://github.com/errbit/errbit/pull/2597

    case response.code.to_i
    when 200..299
      { success: true, data: parse_response(response), status: response.code.to_i }
    when 401
      { success: false, error: 'Unauthorized - Invalid API key', status: 401 }
    when 404
      { success: false, error: 'Not found', status: 404 }
    when 422
      { success: false, error: 'Unprocessable entity', details: parse_response(response), status: 422 }
    else
      { success: false, error: "HTTP #{response.code} - #{response.message}", status: response.code.to_i }
    end
  rescue Net::OpenTimeout, Net::ReadTimeout
    { success: false, error: 'Request timed out', status: 0 }
  rescue JSON::ParserError => e
    { success: false, error: "Invalid JSON response: #{e.message}", status: 0 }
  rescue StandardError => e
    { success: false, error: "Request failed: #{e.message}", status: 0 }
  end

  def parse_response(response)
    return {} if response.body.nil? || response.body.empty?

    puts "response.body: #{response.body}"

    JSON.parse(response.body)
  end
end

# Main entry point
if __FILE__ == $0
  begin
    input = JSON.parse(STDIN.read, symbolize_names: true)
  rescue JSON::ParserError => e
    puts JSON.generate({
      success: false,
      error: "Invalid JSON input: #{e.message}"
    })
    exit 1
  end

  action = input[:action]
  api_key = input[:api_key] || ENV['ERRBIT_API_KEY']
  base_url = input[:base_url] || ENV['ERRBIT_BASE_URL']

  unless action
    puts JSON.generate({
      success: false,
      error: "Missing required parameter: 'action'"
    })
    exit 1
  end

  # All operations require an api_key (each app has its own API key)
  unless api_key
    puts JSON.generate({
      success: false,
      error: "Missing required parameter: 'api_key' - Provide the API key of the app you want to access."
    })
    exit 1
  end

  client = ErrbitClient.new(api_key: api_key, base_url: base_url)

  result = case action
  when 'list_problems'
    client.list_problems(
      start_date: input[:start_date],
      end_date: input[:end_date]
    )
  when 'get_problem'
    unless input[:problem_id]
      puts JSON.generate({
        success: false,
        error: "Missing required parameter: 'problem_id'"
      })
      exit 1
    end
    client.get_problem(
      problem_id: input[:problem_id]
    )
  when 'list_notices'
    client.list_notices(
      start_date: input[:start_date],
      end_date: input[:end_date]
    )
  when 'get_stats'
    client.get_stats
  when 'list_comments'
    unless input[:problem_id]
      puts JSON.generate({
        success: false,
        error: "Missing required parameter: 'problem_id'"
      })
      exit 1
    end
    client.list_comments(
      problem_id: input[:problem_id]
    )
  when 'create_comment'
    unless input[:problem_id] && input[:body]
      puts JSON.generate({
        success: false,
        error: "Missing required parameters: 'problem_id' and 'body'"
      })
      exit 1
    end
    client.create_comment(
      problem_id: input[:problem_id],
      body: input[:body]
    )
  else
    {
      success: false,
      error: "Unknown action: #{action}. Valid actions are: list_problems, get_problem, list_notices, get_stats, list_comments, create_comment"
    }
  end

  puts JSON.generate(result)
end
