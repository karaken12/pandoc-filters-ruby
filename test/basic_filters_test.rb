require_relative 'test_helper'

class BasicFiltersTest < Minitest::Test
  include PandocHelper

  def test_filter_that_does_nothing
    ast = to_pandoc_ast <<-EOF
      # Header

      This is a paragraph

      # Another Header

      This is a paragraph *with emphasis*
    EOF

    output = StringIO.new
    PandocFilter.filter(ast_to_stream(ast), output) { }
    assert_equal(ast, stream_to_ast(output))
  end

  def test_filter_to_affect_headers
    ast = to_pandoc_ast <<-EOF
      # Header

      This is a paragraph

      # Another Header

      This is a paragraph *with emphasis*
    EOF

    output = StringIO.new

    PandocFilter.filter(ast_to_stream(ast), output) do |type, value, _format, _meta|
      next unless type == 'Header'
      PandocElement.Header(value[0], value[1], value[2].map { |node| upcase_if_str_node(node) })
    end

    expected_ast = to_pandoc_ast <<-EOF
      # HEADER

      This is a paragraph

      # ANOTHER HEADER

      This is a paragraph *with emphasis*
    EOF

    assert_equal(expected_ast, stream_to_ast(output))
  end

  def test_filter_using_format
    ast = to_pandoc_ast <<-EOF
      # Header

      This is a paragraph
    EOF

    output = StringIO.new

    PandocFilter.filter(ast_to_stream(ast), output, %w(markdown)) do |type, value, format, _meta|
      next unless type == 'Header'
      PandocElement.Header(value[0], value[1], [{ 't' => 'Str', 'c' => format }])
    end

    expected_ast = to_pandoc_ast <<-EOF
      # markdown {#header}

      This is a paragraph
    EOF

    assert_equal(expected_ast, stream_to_ast(output))
  end

  def test_filter_using_meta
    ast = to_pandoc_ast <<-EOF
      ---
      header: New Header
      ---
      # Header

      This is a paragraph
    EOF

    output = StringIO.new

    PandocFilter.filter(ast_to_stream(ast), output) do |type, value, _format, meta|
      next unless type == 'Header'
      PandocElement.Header(value[0], value[1], meta['header']['c'])
    end

    expected_ast = to_pandoc_ast <<-EOF
      ---
      header: New Header
      ---
      # New Header {#header}

      This is a paragraph
    EOF

    assert_equal(expected_ast, stream_to_ast(output))
  end

  private

  def upcase_if_str_node(node)
    if node['t'] == 'Str'
      PandocElement.Str(node['c'].upcase)
    else
      node
    end
  end
end
