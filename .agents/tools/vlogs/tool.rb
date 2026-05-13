# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'open3'
require 'openssl'

NAMESPACE = 'monitoring'
SERVICE = 'svc/victoria-logs-single-server'
REMOTE_PORT = 9428
LOCAL_PORT = 9428
PF_PIDFILE = '/tmp/vlogs-portforward.pid'

# --- PII scrubbing ---

SCRUB_SECRET_ENV = 'VLOGS_SCRUB_KEY'
SCRUB_HASH_LENGTH = 8

EMAIL_REGEX = /\b[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}\b/

# Field-name patterns (matched against the final segment of dotted keys).
# Deliberately excludes bare "name" — used for logger/controller names.
PII_KEY_PATTERNS = [
  /\A(first|last|full|display|given|family|preferred|subscriber|user|customer|contact|company)_?name\z/i,
  /\Aemail(_address)?\z/i,
  /\A(phone|mobile|telephone|cell)(_number)?\z/i,
  /\A(street|address|city|zip|postcode|postal_code)\z/i,
  /\Assn\z/i,
  /\A(date_of_birth|dob|birthday)\z/i
].freeze

class VLogsTool
  def initialize
    @options = {}
  end

  def scrub_secret
    @scrub_secret ||= begin
      key = ENV[SCRUB_SECRET_ENV]
      if key.nil? || key.strip.empty?
        raise "Error: #{SCRUB_SECRET_ENV} is not set. Add it to your environment or set raw: true to disable scrubbing."
      end
      key.strip
    end
  end

  def scrub_token(value, type)
    hash = OpenSSL::HMAC.hexdigest('SHA256', scrub_secret, value.to_s)[0, SCRUB_HASH_LENGTH]
    "[#{type}:#{hash}]"
  end

  def scrub_pii_key?(key)
    last = key.to_s.split('.').last
    PII_KEY_PATTERNS.any? { |p| p.match?(last) }
  end

  def scrub_string(str)
    str.gsub(EMAIL_REGEX) { |m| scrub_token(m.downcase, 'EMAIL') }
  end

  def scrub(value, key_context = nil)
    case value
    when Hash
      value.each_with_object({}) { |(k, v), h| h[k] = scrub(v, k) }
    when Array
      value.map { |v| scrub(v, key_context) }
    when String
      if key_context && scrub_pii_key?(key_context)
        scrub_token(value, 'PII')
      else
        scrub_string(value)
      end
    else
      value
    end
  end

  # --- Port-forward management ---

  def active_port_forward
    return nil unless File.exist?(PF_PIDFILE)

    lines = File.readlines(PF_PIDFILE).map(&:strip)
    pid = lines[0]&.to_i
    context = lines[1]

    return nil unless pid&.positive? && context

    begin
      Process.kill(0, pid)
      { pid: pid, context: context }
    rescue Errno::ESRCH
      File.delete(PF_PIDFILE)
      nil
    end
  end

  def ensure_port_forward(context)
    existing = active_port_forward
    if existing
      if existing[:context] == context
        return
      else
        Process.kill('TERM', existing[:pid]) rescue nil
        sleep 1
      end
    end

    # Check if port is already in use by something else
    if port_in_use?
      return
    end

    # Validate kubectl context exists
    validate_context(context)

    # Capture stderr to diagnose issues
    stderr_file = '/tmp/vlogs-portforward-err.log'
    pid = spawn(
      'kubectl', '--context', context,
      'port-forward', '-n', NAMESPACE, SERVICE, "#{LOCAL_PORT}:#{REMOTE_PORT}",
      out: File::NULL, err: stderr_file
    )
    Process.detach(pid)
    File.write(PF_PIDFILE, "#{pid}\n#{context}\n")
    sleep 2

    begin
      Process.kill(0, pid)
    rescue Errno::ESRCH
      File.delete(PF_PIDFILE) if File.exist?(PF_PIDFILE)
      error_msg = 'Error: Port-forward failed to start.'
      if File.exist?(stderr_file)
        stderr_content = File.read(stderr_file).strip
        if stderr_content.include?('context was not found')
          error_msg = "Error: kubectl context '#{context}' not found. Run 'kubectl config get-contexts' to see available contexts."
        elsif !stderr_content.empty?
          error_msg = "Error: Port-forward failed - #{stderr_content}"
        end
        File.delete(stderr_file)
      end
      raise error_msg
    end
  end

  def validate_context(context)
    # Check if context exists
    output = `kubectl config get-contexts --output='name' 2>&1`
    valid_contexts = output.lines.map(&:strip).reject(&:empty?)
    
    unless valid_contexts.include?(context)
      available = valid_contexts.join(', ')
      raise "Error: kubectl context '#{context}' not found. Available contexts: #{available}"
    end
  end

  def port_in_use?
    system("lsof -ti:#{LOCAL_PORT} > /dev/null 2>&1")
  end

  def cleanup_port_forward
    existing = active_port_forward
    if existing
      Process.kill('TERM', existing[:pid]) rescue nil
      File.delete(PF_PIDFILE) if File.exist?(PF_PIDFILE)
      {
        status: 'success',
        message: "Port-forward (PID #{existing[:pid]}) stopped.",
        pid: existing[:pid]
      }
    else
      pids = `lsof -ti:#{LOCAL_PORT} 2>/dev/null`.strip
      if pids.empty?
        {
          status: 'success',
          message: 'No active port-forward found.',
          pid: nil
        }
      else
        pids.split("\n").each { |p| Process.kill('TERM', p.to_i) rescue nil }
        File.delete(PF_PIDFILE) if File.exist?(PF_PIDFILE)
        {
          status: 'success',
          message: "Killed process(es) on port #{LOCAL_PORT}.",
          pid: nil
        }
      end
    end
  end

  # --- API helpers ---

  def vlogs_request(endpoint, params = {})
    uri = URI("http://localhost:#{LOCAL_PORT}/select/logsql/#{endpoint}")

    request = Net::HTTP::Post.new(uri)
    request.set_form_data(params)

    response = Net::HTTP.start(uri.hostname, uri.port, open_timeout: 5, read_timeout: 60) do |http|
      http.request(request)
    end

    case response.code.to_i
    when 200
      response.body
    else
      raise "Error: VictoriaLogs returned HTTP #{response.code}\n#{response.body}"
    end
  rescue Errno::ECONNREFUSED
    raise 'Error: Cannot connect to VictoriaLogs. Is port-forward active?'
  rescue Net::OpenTimeout, Net::ReadTimeout
    raise 'Error: Request timed out.'
  end

  def time_params(options)
    params = {}
    params['start'] = options['start'] if options['start']
    params['end'] = options['end'] if options['end']
    params
  end

  # --- Formatters ---

  def format_query_entries(body, raw: false)
    entries = []
    body.each_line do |line|
      line = line.strip
      next if line.empty?

      obj = JSON.parse(line)
      obj = scrub(obj) unless raw
      entries << obj
    end
    entries
  end

  def build_table_lines(entries)
    entries.map do |obj|
      time = obj['_time']&.then { |t| t[11, 8] } || ''
      level = obj['level'] || ''
      app = (obj['application'] || '')[/make-(.+)/, 1] || obj['application'] || ''
      name = obj['name'] || ''
      message = obj['message'] || ''
      duration = obj['duration_ms'] ? "#{obj['duration_ms'].to_f.round(1)}ms" : ''

      method = obj['payload.method'] || ''
      path = obj['payload.path'] || ''
      status = obj['payload.status']&.to_s || ''
      db = obj['payload.db_runtime'] ? "db=#{obj['payload.db_runtime'].to_f.round(1)}ms" : ''
      queries = obj['payload.queries_count'] ? "q=#{obj['payload.queries_count']}" : ''

      exc_name = obj['exception.name'] || ''
      exc_msg = obj['exception.message'] || ''

      # Build a compact line
      parts = [time, level.upcase.ljust(5)]

      parts << app unless app.empty?
      parts << name unless name.empty?

      if !exc_name.empty?
        parts << "#{exc_name}: #{exc_msg}"[0, 120]
      elsif !message.empty?
        msg_parts = [message]
        msg_parts << "#{method} #{path}" unless path.empty?
        msg_parts << status unless status.empty?
        msg_parts << duration unless duration.empty?
        msg_parts << db unless db.empty?
        msg_parts << queries unless queries.empty?
        parts << msg_parts.join(' | ')
      end

      parts.join('  ')
    end
  end

  def format_stat_value(val)
    return '?' unless val

    num = val.to_f
    if num == num.to_i.to_f && num.abs < 1_000_000
      num.to_i.to_s
    elsif num.abs >= 1000
      format('%.1f', num)
    elsif num.abs >= 1
      format('%.2f', num)
    else
      format('%.4f', num)
    end
  end

  def format_stats_table(data)
    results = data.dig('data', 'result') || []
    return [] if results.empty?

    group_keys = results.first['metric'].keys - ['__name__']

    if group_keys.empty?
      # Simple stats without group-by
      return results.map do |r|
        name = r.dig('metric', '__name__') || '?'
        val = r['value']&.[](1) || '?'
        "#{name}: #{format_stat_value(val)}"
      end
    end

    # Build a table
    rows = {}
    columns = []
    results.each do |r|
      metric_name = r.dig('metric', '__name__') || '?'
      columns << metric_name unless columns.include?(metric_name)
      key = group_keys.map { |k| r.dig('metric', k) || '' }.join(' | ')
      rows[key] ||= {}
      rows[key][metric_name] = r['value']&.[](1)
    end

    header_parts = group_keys.map { |k| k.split('.').last }
    col_widths = columns.map { |c| [c.length, 10].max }

    lines = []
    header = header_parts.join(' | ').ljust(40) + columns.each_with_index.map { |c, i| c.rjust(col_widths[i]) }.join('  ')
    lines << header
    lines << '-' * header.length

    sorted = rows.sort_by { |_, vals| -(vals[columns.first]&.to_f || 0) }
    sorted.each do |key, vals|
      line = key.ljust(40)
      columns.each_with_index do |col, i|
        line += format_stat_value(vals[col]).rjust(col_widths[i]) + '  '
      end
      lines << line
    end
    lines
  end

  # --- Commands ---

  def cmd_query(options)
    params = { 'query' => options['query'] || '*', 'limit' => (options['limit'] || 50).to_s }
    params.merge!(time_params(options))

    body = vlogs_request('query', params)
    entries = format_query_entries(body, raw: options['raw'])

    if options['format'] == 'table'
      table_lines = build_table_lines(entries)
      {
        command: 'query',
        format: 'table',
        entries: entries,
        table_lines: table_lines,
        count: entries.length
      }
    else
      {
        command: 'query',
        format: 'json',
        entries: entries,
        count: entries.length
      }
    end
  end

  def cmd_stats(options)
    params = { 'query' => options['query'] || '*' }
    params.merge!(time_params(options))

    body = vlogs_request('stats_query', params)
    data = JSON.parse(body)
    data = scrub(data) unless options['raw']

    if options['format'] == 'table'
      table_lines = format_stats_table(data)
      {
        command: 'stats',
        format: 'table',
        data: data,
        table_lines: table_lines
      }
    else
      {
        command: 'stats',
        format: 'json',
        data: data
      }
    end
  end

  def cmd_fields(options)
    params = { 'query' => options['query'] || '*' }
    params.merge!(time_params(options))

    body = vlogs_request('field_names', params)
    data = JSON.parse(body)
    fields = data['values'] || []

    if options['format'] == 'table'
      table_lines = fields.map { |v| "#{v['value'].ljust(50)} #{v['hits']} hits" }
      {
        command: 'fields',
        format: 'table',
        fields: fields,
        table_lines: table_lines,
        count: fields.length
      }
    else
      {
        command: 'fields',
        format: 'json',
        fields: fields,
        count: fields.length
      }
    end
  end

  def cmd_values(options)
    raise 'Error: field is required for the values command.' unless options['field']

    params = { 'query' => options['query'] || '*', 'field' => options['field'] }
    params.merge!(time_params(options))

    body = vlogs_request('field_values', params)
    data = JSON.parse(body)

    unless options['raw']
      field = options['field']
      (data['values'] || []).each do |v|
        v['value'] = scrub(v['value'], field) if v['value'].is_a?(String)
      end
    end

    values = data['values'] || []

    if options['format'] == 'table'
      table_lines = values.map { |v| "#{v['value'].to_s.ljust(50)} #{v['hits']} hits" }
      {
        command: 'values',
        format: 'table',
        field: options['field'],
        values: values,
        table_lines: table_lines,
        count: values.length
      }
    else
      {
        command: 'values',
        format: 'json',
        field: options['field'],
        values: values,
        count: values.length
      }
    end
  end

  def cmd_hits(options)
    params = { 'query' => options['query'] || '*' }
    params.merge!(time_params(options))
    params['field'] = options['field'] if options['field']

    body = vlogs_request('hits', params)
    data = JSON.parse(body)

    {
      command: 'hits',
      data: data
    }
  end

  def cmd_cleanup(_options)
    result = cleanup_port_forward
    result.merge(command: 'cleanup')
  end

  # --- Main entry point ---

  def run(input)
    command = input['command']
    raise 'Error: command is required' unless command

    if command == 'cleanup'
      return cmd_cleanup(input)
    end

    raise 'Error: context is required' unless input['context']

    ensure_port_forward(input['context'])

    case command
    when 'query'  then cmd_query(input)
    when 'stats'  then cmd_stats(input)
    when 'fields' then cmd_fields(input)
    when 'values' then cmd_values(input)
    when 'hits'   then cmd_hits(input)
    else
      raise "Error: Unknown command '#{command}'"
    end
  rescue => e
    {
      error: true,
      message: e.message
    }
  end
end

# --- Read from stdin and execute ---

begin
  input = JSON.parse(STDIN.read)
  tool = VLogsTool.new
  result = tool.run(input)
  puts JSON.generate(result)
rescue JSON::ParserError => e
  puts JSON.generate({ error: true, message: "Invalid JSON input: #{e.message}" })
rescue => e
  puts JSON.generate({ error: true, message: e.message })
end
