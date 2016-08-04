require_relative 'test_helper'

class AstTest < Minitest::Test
  def test_space
    assert_equal({ 't' => 'Space', 'c' => [] }, PandocElement::Space.new.to_ast)
  end

  def test_str
    assert_equal({ 't' => 'Str', 'c' => 'hello' }, PandocElement::Str.new('hello').to_ast)
  end

  def test_to_ast_with_object
    assert_equal({ 't' => 'Space', 'c' => [] }, PandocElement.to_ast(PandocElement::Space.new))
  end

  def test_to_ast_with_array
    expected = [
      { 't' => 'Str', 'c' => 'hello' },
      { 't' => 'Space', 'c' => [] },
      { 't' => 'Str', 'c' => 'world' }
    ]

    actual = PandocElement.to_ast([
      PandocElement::Str.new('hello'),
      PandocElement::Space.new,
      PandocElement::Str.new('world')
    ])

    assert_equal(expected, actual)
  end

  def test_to_ast_with_hash
    expected = { 'x' => 'value', 'y' => { 't' => 'Space', 'c' => [] } }
    actual = PandocElement.to_ast('x' => 'value', 'y' => PandocElement::Space.new)
    assert_equal(expected, actual)
  end

  def test_to_ast_with_string
    assert_equal('hello', PandocElement.to_ast('hello'))
  end

  def test_para
    expected = {
      't' => 'Para', 'c' => [
        { 't' => 'Str', 'c' => 'hello' },
        { 't' => 'Space', 'c' => [] },
        { 't' => 'Str', 'c' => 'world' }
      ]
    }

    actual = PandocElement::Para.new([
      PandocElement::Str.new('hello'),
      PandocElement::Space.new,
      PandocElement::Str.new('world')
    ]).to_ast

    assert_equal(expected, actual)
  end
end
