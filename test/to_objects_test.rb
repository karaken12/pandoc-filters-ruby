require_relative 'test_helper'

class ToObjectsTest < Minitest::Test
  include PandocHelper
  include PandocAstHelper
  include PandocElementHelper

  def test_space
    assert_equal(space, PandocElement.to_object(space_ast))
  end

  def test_str
    assert_equal(hello_str, PandocElement.to_object(hello_str_ast))
  end

  def test_with_array
    expected = [hello_str, space, world_str]
    actual = PandocElement.to_object([hello_str_ast, space_ast, world_str_ast])
    assert_equal(expected, actual)
  end

  def test_with_non_ast_hash
    expected = { 'x' => 'value', 'y' => space }
    actual = PandocElement.to_object('x' => 'value', 'y' => space_ast)
    assert_equal(expected, actual)
  end

  def test_with_string
    assert_equal('hello', PandocElement.to_object('hello'))
  end

  def test_para
    expected = para(hello_str, space, world_str)
    actual = PandocElement.to_object(para_ast(hello_str_ast, space_ast, world_str_ast))
    assert_equal(expected, actual)
  end

  def test_link
    expected = PandocElement::Link.new([
      PandocElement::Attr.new(['id', ['class1', 'class2'], [['key1', 'value1'], ['key2', 'value2']]]),
      [PandocElement::Str.new('link')],
      PandocElement::Target.new(['http://example.com', 'This is the title'])
    ])

    actual = PandocElement.to_object(ast('Link', [
      ['id', ['class1', 'class2'], [['key1', 'value1'], ['key2', 'value2']]],
      [ast('Str', 'link')],
      ['http://example.com', 'This is the title']
    ]))

    assert_equal(expected, actual)
  end
end
