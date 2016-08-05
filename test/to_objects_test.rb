require_relative 'test_helper'

class ToObjectsTest < Minitest::Test
  def test_space
    assert_equal(PandocElement::Space.new, PandocElement.to_object('t' => 'Space', 'c' => []))
  end

  def test_str
    assert_equal(PandocElement::Str.new('hello'), PandocElement.to_object('t' => 'Str', 'c' => 'hello'))
  end

  def test_with_array
    expected = [
      PandocElement::Str.new('hello'),
      PandocElement::Space.new,
      PandocElement::Str.new('world')
    ]

    actual = PandocElement.to_object([
      { 't' => 'Str', 'c' => 'hello' },
      { 't' => 'Space', 'c' => [] },
      { 't' => 'Str', 'c' => 'world' }
    ])

    assert_equal(expected, actual)
  end

  def test_with_non_ast_hash
    expected = { 'x' => 'value', 'y' => PandocElement::Space.new }
    actual = PandocElement.to_object('x' => 'value', 'y' => { 't' => 'Space', 'c' => [] })
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

    actual = PandocElement.to_object(
      't' => 'Para', 'c' => [
        { 't' => 'Str', 'c' => 'hello' },
        { 't' => 'Space', 'c' => [] },
        { 't' => 'Str', 'c' => 'world' }
      ]
    )

    assert_equal(expected, actual)
  end

  def test_link
    expected = PandocElement::Link.new([
      PandocElement::Attr.new(['id', ['class1', 'class2'], [['key1', 'value1'], ['key2', 'value2']]]),
      [PandocElement::Str.new('link')],
      PandocElement::Target.new(['http://example.com', 'This is the title'])
    ])

    actual = PandocElement.to_object(
      't' => 'Link', 'c' => [
        ['id', ['class1', 'class2'], [['key1', 'value1'], ['key2', 'value2']]],
        [{ 't' => 'Str', 'c' => 'link' }],
        ['http://example.com', 'This is the title']
      ]
    )

    assert_equal(expected, actual)
  end
end
