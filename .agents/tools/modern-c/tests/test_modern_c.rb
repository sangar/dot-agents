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
      ['ascii-text', 'src/main.c', 44],
      ['ascii-text', 'src/main.c', 44],
      ['build-system', 'Makefile', nil],
      ['clang-tidy', nil, nil],
      ['dep-leak', 'src/main.c', 4],
      ['dep-leak', 'src/other.c', 1],
      ['dep-leak', 'src/store.h', 3],
      ['dep-leak', 'src/store.h', 3],
      ['deps-lock', 'deps.lock', 2],
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
      ['ndebug', 'CMakeLists.txt', 3],
      ['ndebug', 'CMakeLists.txt', nil],
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

  def test_dep_leak_matches_include_paths_not_basenames
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, 'src'))
      FileUtils.mkdir_p(File.join(dir, 'deps', 'curl', 'lib', 'curlx'))
      File.write(File.join(dir, 'deps', 'curl', 'lib', 'curlx', 'wait.h'), "#pragma once\n")
      File.write(File.join(dir, 'src', 'a.c'), "#include <sys/wait.h>\n#include \"curlx/wait.h\"\n")
      File.write(File.join(dir, 'src', 'b.c'), "#include <sys/wait.h>\n#include \"lib/curlx/wait.h\"\n")
      result = run_check(dir)
      sites = result['findings'].select { |f| f['rule'] == 'dep-leak' }.map { |f| [f['file'], f['line']] }
      assert_equal [['src/a.c', 2], ['src/b.c', 2]], sites.sort
    end
  end

  def test_dep_leak_allows_one_wrapper_directory_below_src
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, 'deps', 'curl', 'include', 'curl'))
      File.write(File.join(dir, 'deps', 'curl', 'include', 'curl', 'curl.h'), "#pragma once\n")
      %w[src/net/http.c src/net/smtp.c src/app/feed.c].each do |file|
        FileUtils.mkdir_p(File.join(dir, File.dirname(file)))
        File.write(File.join(dir, file), "#include <curl/curl.h>\n")
      end
      sites = run_check(dir)['findings'].select { |f| f['rule'] == 'dep-leak' }.map { |f| f['file'] }
      assert_equal %w[src/app/feed.c src/net/http.c src/net/smtp.c], sites.sort

      FileUtils.rm(File.join(dir, 'src', 'app', 'feed.c'))
      assert_empty run_check(dir)['findings'].select { |f| f['rule'] == 'dep-leak' }
    end
  end

  def test_ascii_text_ignores_declarations_and_definitions
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, 'src'))
      File.write(File.join(dir, 'src', 'str.h'), "String str_lower_ascii(Arena *arena, String s);\n")
      File.write(File.join(dir, 'src', 'str.c'), "static inline int tolower(int c)\n{\n    return c;\n}\n")
      result = run_check(dir)
      assert_empty result['findings'].select { |f| f['rule'] == 'ascii-text' }
    end
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

  def test_ndebug_in_build_c_is_reported_where_it_is_defined
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, 'tools'))
      File.write(File.join(dir, 'tools', 'build.c'), <<~C)
        static const char *const DEBUG_FLAGS[] = { "-g", "-UNDEBUG" };
        static const char *const RELEASE_FLAGS[] = { "-O2", "-DNDEBUG" };
      C
      sites = run_check(dir, '--level', '1')['findings'].select { |f| f['rule'] == 'ndebug' }
      assert_equal [['tools/build.c', 2]], sites.map { |f| [f['file'], f['line']] }
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

  def test_hash_ignores_what_a_dependency_build_creates
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'lib.c'), "int lib;\n")
      before, = Open3.capture2('ruby', TOOL, 'hash', dir)
      %w[deps/curl out].each { |sub| FileUtils.mkdir_p(File.join(dir, sub)) }
      File.write(File.join(dir, 'deps', 'curl', 'curl.c'), "int curl;\n")
      File.write(File.join(dir, 'nob'), 'binary')
      after, = Open3.capture2('ruby', TOOL, 'hash', dir)
      assert_equal before, after
    end
  end

  def test_deps_lock_accepts_archive_lines_that_match_a_source_line
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, 'deps', 'curl'))
      File.write(File.join(dir, 'deps', 'curl', 'curl.c'), "int curl;\n")
      source_hash, = Open3.capture2('ruby', TOOL, 'hash', File.join(dir, 'deps', 'curl'))
      archive = "https://github.com/sangar/libmc/releases/download/deps-curl-8.23.0/curl.tar.gz sha256:#{'a' * 64}"
      File.write(File.join(dir, 'deps.lock'), <<~LOCK)
        curl 8.23.0 https://github.com/curl/curl #{source_hash.strip}
        curl 8.23.0 macos-aarch64 #{archive}
        curl 8.23.0 linux-x86_64 #{archive}
        curl 8.22.0 linux-aarch64 #{archive}
      LOCK
      result = run_check(dir)
      sites = result['findings'].select { |f| f['rule'] == 'deps-lock' }.map { |f| [f['file'], f['line']] }
      assert_equal [['deps.lock', 4]], sites
    end
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
