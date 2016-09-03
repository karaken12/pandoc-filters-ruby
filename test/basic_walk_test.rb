require_relative 'test_helper'

class BasicWalkTest < Minitest::Test
  include PandocHelper
  include PandocAstHelper

  def setup
    @types = []
    @values = []
  end

  def test_walk_of_single_element
    filter = PandocFilter.new { |type, value| @types << type; @values << value; nil }
    result = filter.walk(hello_str_ast)
    assert_empty(@types)
    assert_empty(@values)
    assert_equal(hello_str_ast, result)
  end

  def test_walk_of_array_of_elements
    filter = PandocFilter.new { |type, value| @types << type; @values << value; nil }
    result = filter.walk([hello_str_ast, space_ast, world_str_ast])
    assert_equal(['Str', 'Space', 'Str'], @types)
    assert_equal(['hello', [], 'world'], @values)
    assert_equal([hello_str_ast, space_ast, world_str_ast], result)
  end

  def test_walk_of_hash_of_elements
    filter = PandocFilter.new { |type, value| @types << type; @values << value; nil }
    result = filter.walk('x' => [space_ast], 'y' => [soft_break_ast], 'z' => [null_ast])
    assert_equal(['Space', 'SoftBreak', 'Null'], @types)
    assert_equal([[], [], []], @values)
    assert_equal({ 'x' => [space_ast], 'y' => [soft_break_ast], 'z' => [null_ast] }, result)
  end

  def test_nested_walk
    filter = PandocFilter.new { |type, value| @types << type; @values << value; nil }
    result = filter.walk([para_ast(hello_str_ast, space_ast, world_str_ast)])
    assert_equal(['Para', 'Str', 'Space', 'Str'], @types)
    assert_equal([[hello_str_ast, space_ast, world_str_ast], 'hello', [], 'world'], @values)
    assert_equal([para_ast(hello_str_ast, space_ast, world_str_ast)], result)
  end

  def test_walk_replacing_certain_elements
    filter = PandocFilter.new { |type, value| @types << type; @values << value; space_ast if type == 'Str' }
    result = filter.walk([para_ast(hello_str_ast, space_ast, world_str_ast)])
    assert_equal(['Para', 'Str', 'Space', 'Str'], @types)
    assert_equal([[hello_str_ast, space_ast, world_str_ast], 'hello', [], 'world'], @values)
    assert_equal([para_ast(space_ast, space_ast, space_ast)], result)
  end

  def test_walk_replacing_certain_elements_with_nested_elements
    filter = PandocFilter.new { |type, value| @types << type; @values << value; plain_ast(soft_break_ast) if type == 'Str' }
    result = filter.walk([para_ast(hello_str_ast, space_ast, world_str_ast)])
    assert_equal(['Para', 'Str', 'SoftBreak', 'Space', 'Str', 'SoftBreak'], @types)
    assert_equal([[hello_str_ast, space_ast, world_str_ast], 'hello', [], [], 'world', []], @values)
    assert_equal([para_ast(plain_ast(soft_break_ast), space_ast, plain_ast(soft_break_ast))], result)
  end

  def test_walk_of_hash_of_elements_replacing_some_elements
    filter = PandocFilter.new { |type, value| @types << type; @values << value; line_break_ast if type == 'Null' }
    result = filter.walk('x' => [space_ast], 'y' => [soft_break_ast], 'z' => [null_ast])
    assert_equal(['Space', 'SoftBreak', 'Null'], @types)
    assert_equal([[], [], []], @values)
    assert_equal({ 'x' => [space_ast], 'y' => [soft_break_ast], 'z' => [line_break_ast] }, result)
  end

  def test_walk_and_remove_element
    filter = PandocFilter.new { |type, value| @types << type; @values << value; [] if type == 'Str' }
    result = filter.walk([para_ast(hello_str_ast, space_ast, world_str_ast)])
    assert_equal(['Para', 'Str', 'Space', 'Str'], @types)
    assert_equal([[hello_str_ast, space_ast, world_str_ast], 'hello', [], 'world'], @values)
    assert_equal([para_ast(space_ast)], result)
  end

  def test_walk_and_add_elements
    filter = PandocFilter.new { |type, value| @types << type; @values << value; [line_break_ast, ast(type, value)] if type == 'Str' }
    result = filter.walk([para_ast(hello_str_ast, space_ast, world_str_ast)])
    assert_equal(['Para', 'Str', 'Space', 'Str'], @types)
    assert_equal([[hello_str_ast, space_ast, world_str_ast], 'hello', [], 'world'], @values)
    assert_equal([para_ast(line_break_ast, hello_str_ast, space_ast, line_break_ast, world_str_ast)], result)
  end
end
