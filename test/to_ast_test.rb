require_relative 'test_helper'

class ToAstTest < Minitest::Test
  include PandocHelper

  def test_space
    assert_equal(ast('Space'), PandocElement::Space.new.to_ast)
  end

  def test_str
    assert_equal(ast('Str', 'hello'), PandocElement::Str.new('hello').to_ast)
  end

  def test_with_object
    assert_equal(ast('Space'), PandocElement.to_ast(PandocElement::Space.new))
  end

  def test_with_array
    expected = [ast('Str', 'hello'), ast('Space'), ast('Str', 'world')]

    actual = PandocElement.to_ast([
      PandocElement::Str.new('hello'),
      PandocElement::Space.new,
      PandocElement::Str.new('world')
    ])

    assert_equal(expected, actual)
  end

  def test_with_hash
    expected = { 'x' => 'value', 'y' => ast('Space') }
    actual = PandocElement.to_ast('x' => 'value', 'y' => PandocElement::Space.new)
    assert_equal(expected, actual)
  end

  def test_with_string
    assert_equal('hello', PandocElement.to_ast('hello'))
  end

  def test_para
    expected = ast('Para', [ast('Str', 'hello'), ast('Space'), ast('Str', 'world')])

    actual = PandocElement::Para.new([
      PandocElement::Str.new('hello'),
      PandocElement::Space.new,
      PandocElement::Str.new('world')
    ]).to_ast

    assert_equal(expected, actual)
  end

  def test_link
    expected = ast('Link', [
      ['id', ['class1', 'class2'], [['key1', 'value1'], ['key2', 'value2']]],
      [ast('Str', 'link')],
      ['http://example.com', 'This is the title']
    ])

    actual = PandocElement::Link.new([
      PandocElement::Attr.new(['id', ['class1', 'class2'], [['key1', 'value1'], ['key2', 'value2']]]),
      [PandocElement::Str.new('link')],
      PandocElement::Target.new(['http://example.com', 'This is the title'])
    ]).to_ast

    assert_equal(expected, actual)
  end
end
