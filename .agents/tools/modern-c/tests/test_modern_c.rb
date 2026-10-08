# frozen_string_literal: true

require 'minitest/autorun'
require 'json'
require 'open3'
require 'tmpdir'
require 'fileutils'

class ModernCTest < Minitest::Test
  TOOL = File.expand_path('../modern-c', __dir__)
  FIXTURES = File.expand_path('fixtures', __dir__)

  def run_check(path, *args)
    stdout, stderr, status = Open3.capture3('ruby', TOOL, 'check', path, '--format', 'json', *args)
    assert_includes [0, 1], status.exitstatus, stderr
    JSON.parse(stdout)
  end

  def test_clean_project_has_no_findings
    result = run_check(File.join(FIXTURES, 'clean'))
    assert result['success'], result['findings'].map { |f| f.values_at('file', 'line', 'rule', 'message').join(' ') }.join("\n")
    assert_equal 3, result['level']
  end

  def test_violations_fixture_triggers_every_rule_once_per_site
    result = run_check(File.join(FIXTURES, 'violations'), '--level', '3')
    sites = result['findings'].map { |f| [f['rule'], f['file'], f['line']] }
    expected = [
      ['build-system', 'Makefile', nil],
      ['clang-tidy', nil, nil],
      ['dep-leak', 'src/main.c', 4],
      ['dep-leak', 'src/other.c', 1],
      ['dep-leak', 'src/store.h', 3],
      ['dep-leak', 'src/store.h', 3],
      ['deps-lock', 'deps.lock', 2],
      ['deps-lock', 'deps.lock', 3],
      ['deps-lock', 'deps.lock', 4],
      ['deps-lock', 'deps/zlib', nil],
      ['errno', 'src/main.c', 35],
      ['function-macro', 'src/main.c', 17],
      ['fuzz', nil, nil],
      ['global-mutable', 'src/main.c', 21],
      ['global-mutable', 'src/main.c', 22],
      ['layout', 'vendor', nil],
      ['layout', nil, nil],
      ['malloc', 'src/main.c', 33],
      ['malloc', 'src/main.c', 37],
      ['nodiscard', 'src/other.c', 4],
      ['nodiscard', 'src/store.h', 8],
      ['platform-header', 'src/main.c', 3],
      ['platform-ifdef', 'src/main.c', 11],
      ['readme-profile', 'README.md', nil],
      ['readme-profile', 'README.md', nil],
      ['sanitizers', 'CMakeLists.txt', nil],
      ['stdc-version', 'src/main.c', 7],
      ['warnings', 'CMakeLists.txt', nil],
      ['warnings', 'CMakeLists.txt', nil],
      ['warnings', 'CMakeLists.txt', nil]
    ]
    assert_equal expected.sort_by(&:to_s), sites.sort_by(&:to_s)
    refute result['success']
  end

  def test_level_one_skips_project_structure_rules
    result = run_check(File.join(FIXTURES, 'violations'), '--level', '1')
    assert result['findings'].all? { |f| f['level'] == 1 }
    assert_includes result['summary'].keys, 'global-mutable'
    refute_includes result['summary'].keys, 'deps-lock'
  end

  def test_allow_comments_suppress_findings
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, 'src'))
      File.write(File.join(dir, 'src', 'a.c'), <<~C)
        // modern-c: allow-file errno
        static int suppressed; // modern-c: allow global-mutable
        static int reported;
        int code = errno;
      C
      result = run_check(dir, '--level', '1')
      sites = result['findings'].map { |f| [f['rule'], f['line']] }
      assert_equal [['global-mutable', 3], ['global-mutable', 4]], sites.sort
    end
  end

  def test_build_output_directory_is_not_a_bazel_build_file
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'CMakeLists.txt'), '')
      FileUtils.mkdir_p(File.join(dir, 'build'))
      result = run_check(dir, '--level', '2')
      assert_empty result['findings'].select { |f| f['rule'] == 'build-system' }
    end
  end

  def test_hash_is_stable_and_matches_lock_entry
    dir = File.join(FIXTURES, 'clean', 'deps', 'yyjson')
    first, = Open3.capture2('ruby', TOOL, 'hash', dir)
    second, = Open3.capture2('ruby', TOOL, 'hash', dir)
    assert_equal first, second
    assert_includes File.read(File.join(FIXTURES, 'clean', 'deps.lock')), first.strip
  end

  def test_stdin_json_input_reports_json
    input = JSON.generate('command' => 'check', 'path' => File.join(FIXTURES, 'clean'), 'level' => 1)
    stdout, _, status = Open3.capture3('ruby', TOOL, stdin_data: input)
    assert_equal 0, status.exitstatus
    assert_equal 1, JSON.parse(stdout)['level']
  end

  def test_unknown_command_exits_two
    _, stderr, status = Open3.capture3('ruby', TOOL, 'lint')
    assert_equal 2, status.exitstatus
    assert_match(/unknown command lint/, stderr)
  end
end
