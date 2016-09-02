require_relative 'test_helper'

class ObjectFiltersTest < Minitest::Test
  include PandocHelper

  def test_filter_that_does_nothing
    ast = to_pandoc_ast <<-EOF
      # Header

      This is a paragraph

      # Another Header

      This is a paragraph *with emphasis*
    EOF

    output = StringIO.new
    PandocElement.filter(ast_to_stream(ast), output) { }
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

    PandocElement.filter(ast_to_stream(ast), output) do |element|
      next unless element.kind_of?(PandocElement::Header)
      element.walk { |e| e.value.upcase! if e.respond_to?(:value) }
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
    filter = PandocElement::Filter.new(ast_to_stream(ast), output, %w(markdown))

    filter.filter do |element|
      next unless element.kind_of?(PandocElement::Header)
      element.elements = [PandocElement::Str.new(filter.format)]
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
    filter = PandocElement::Filter.new(ast_to_stream(ast), output)

    filter.filter do |element|
      next unless element.kind_of?(PandocElement::Header)
      element.elements = filter.meta["header"].contents
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
end
