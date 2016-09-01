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
end
