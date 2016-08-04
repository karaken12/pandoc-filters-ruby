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
end
