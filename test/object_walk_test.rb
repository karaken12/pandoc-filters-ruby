require_relative 'test_helper'

class ObjectWalkTest < Minitest::Test
  include PandocElementHelper

  def setup
    @elements = []
  end

  def test_walk_of_single_element
    result = PandocElement.walk(hello_str) { |element| @elements << element.dup; nil }
    assert_empty(@elements)
    assert_equal(hello_str, result)
  end

  def test_walk_of_array_of_elements
    result = PandocElement.walk([hello_str, space, world_str]) { |element| @elements << element.dup; nil }
    assert_equal([hello_str, space, world_str], @elements)
    assert_equal([hello_str, space, world_str], result)
  end

  def test_walk_of_hash_of_elements
    result = PandocElement.walk('x' => [space], 'y' => [soft_break], 'z' => [null]) { |element| @elements << element.dup; nil }
    assert_equal([space, soft_break, null], @elements)
    assert_equal({ 'x' => [space], 'y' => [soft_break], 'z' => [null] }, result)
  end

  def test_nested_walk
    result = PandocElement.walk([para(hello_str, space, world_str)]) { |element| @elements << element.dup; nil }
    assert_equal([para(hello_str, space, world_str), hello_str, space, world_str], @elements)
    assert_equal([para(hello_str, space, world_str)], result)
  end

  def test_walk_doesnt_replace_elements
    result = PandocElement.walk([para(hello_str, space, world_str)]) { |element| @elements << element.dup; space if element.kind_of?(PandocElement::Str) }
    assert_equal([para(hello_str, space, world_str), hello_str, space, world_str], @elements)
    assert_equal([para(hello_str, space, world_str)], result)
  end

  def test_walk_doesnt_replace_elements_with_nested_elements
    result = PandocElement.walk([para(hello_str, space, world_str)]) { |element| @elements << element.dup; plain(soft_break) if element.kind_of?(PandocElement::Str) }
    assert_equal([para(hello_str, space, world_str), hello_str, space, world_str], @elements)
    assert_equal([para(hello_str, space, world_str)], result)
  end

  def test_walk_of_hash_of_elements_doesnt_replace_elements
    result = PandocElement.walk('x' => [space], 'y' => [soft_break], 'z' => [null]) { |element| @elements << element.dup; line_break if element.kind_of?(PandocElement::Null) }
    assert_equal([space, soft_break, null], @elements)
    assert_equal({ 'x' => [space], 'y' => [soft_break], 'z' => [null] }, result)
  end

  def test_walk_doesnt_remove_elements
    result = PandocElement.walk([para(hello_str, space, world_str)]) { |element| @elements << element.dup; [] if element.kind_of?(PandocElement::Str) }
    assert_equal([para(hello_str, space, world_str), hello_str, space, world_str], @elements)
    assert_equal([para(hello_str, space, world_str)], result)
  end

  def test_walk_doesnt_add_elements
    result = PandocElement.walk([para(hello_str, space, world_str)]) { |element| @elements << element.dup; [line_break, element] if element.kind_of?(PandocElement::Str) }
    assert_equal([para(hello_str, space, world_str), hello_str, space, world_str], @elements)
    assert_equal([para(hello_str, space, world_str)], result)
  end
end
