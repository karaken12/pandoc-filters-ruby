require_relative 'test_helper'

class ToObjectsTest < Minitest::Test
  include PandocHelper

  def test_space
    assert_equal(PandocElement::Space.new, PandocElement.to_object(ast('Space')))
  end

  def test_str
    assert_equal(PandocElement::Str.new('hello'), PandocElement.to_object(ast('Str', 'hello')))
  end

  def test_with_array
    expected = [
      PandocElement::Str.new('hello'),
      PandocElement::Space.new,
      PandocElement::Str.new('world')
    ]

    actual = PandocElement.to_object([ast('Str', 'hello'), ast('Space'), ast('Str', 'world')])
    assert_equal(expected, actual)
  end

  def test_with_non_ast_hash
    expected = { 'x' => 'value', 'y' => PandocElement::Space.new }
    actual = PandocElement.to_object('x' => 'value', 'y' => ast('Space'))
    assert_equal(expected, actual)
  end

  def test_with_string
    assert_equal('hello', PandocElement.to_object('hello'))
  end

  def test_para
    expected = PandocElement::Para.new([
      PandocElement::Str.new('hello'),
      PandocElement::Space.new,
      PandocElement::Str.new('world')
    ])

    actual = PandocElement.to_object(ast('Para', [ast('Str', 'hello'), ast('Space'), ast('Str', 'world')]))
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
