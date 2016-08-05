require_relative 'test_helper'

class BasicWalkTest < Minitest::Test
  include PandocHelper

  def setup
    @types = []
    @values = []
  end

  def test_walk_of_single_element
    filter = PandocFilter.new { |type, value| @types << type; @values << value; nil }
    result = filter.walk(ast('Str', 'hello'))
    assert_empty(@types)
    assert_empty(@values)
    assert_equal(ast('Str', 'hello'), result)
  end

  def test_walk_of_array_of_elements
    filter = PandocFilter.new { |type, value| @types << type; @values << value; nil }
    result = filter.walk([ast('Str', 'hello'), ast('Space'), ast('Str', 'world')])
    assert_equal(['Str', 'Space', 'Str'], @types)
    assert_equal(['hello', [], 'world'], @values)
    assert_equal([ast('Str', 'hello'), ast('Space'), ast('Str', 'world')], result)
  end

  def test_walk_of_hash_of_elements
    filter = PandocFilter.new { |type, value| @types << type; @values << value; nil }
    result = filter.walk('x' => [ast('Space')], 'y' => [ast('SoftBreak')], 'z' => [ast('Null')])
    assert_equal(['Space', 'SoftBreak', 'Null'], @types)
    assert_equal([[], [], []], @values)
    assert_equal({ 'x' => [ast('Space')], 'y' => [ast('SoftBreak')], 'z' => [ast('Null')] }, result)
  end

  def test_nested_walk
    filter = PandocFilter.new { |type, value| @types << type; @values << value; nil }
    result = filter.walk([ast('Para', [ast('Str', 'hello'), ast('Space'), ast('Str', 'world')])])
    assert_equal(['Para', 'Str', 'Space', 'Str'], @types)
    assert_equal([[ast('Str', 'hello'), ast('Space'), ast('Str', 'world')], 'hello', [], 'world'], @values)
    assert_equal([ast('Para', [ast('Str', 'hello'), ast('Space'), ast('Str', 'world')])], result)
  end

  def test_walk_replacing_certain_elements
    filter = PandocFilter.new { |type, value| @types << type; @values << value; ast('Space') if type == 'Str' }
    result = filter.walk([ast('Para', [ast('Str', 'hello'), ast('Space'), ast('Str', 'world')])])
    assert_equal(['Para', 'Str', 'Space', 'Str'], @types)
    assert_equal([[ast('Str', 'hello'), ast('Space'), ast('Str', 'world')], 'hello', [], 'world'], @values)
    assert_equal([ast('Para', [ast('Space'), ast('Space'), ast('Space')])], result)
  end

  def test_walk_replacing_certain_elements_with_nested_elements
    filter = PandocFilter.new { |type, value| @types << type; @values << value; ast('Plain', [ast('SoftBreak')]) if type == 'Str' }
    result = filter.walk([ast('Para', [ast('Str', 'hello'), ast('Space'), ast('Str', 'world')])])
    assert_equal(['Para', 'Str', 'SoftBreak', 'Space', 'Str', 'SoftBreak'], @types)
    assert_equal([[ast('Str', 'hello'), ast('Space'), ast('Str', 'world')], 'hello', [], [], 'world', []], @values)
    assert_equal([ast('Para', [ast('Plain', [ast('SoftBreak')]), ast('Space'), ast('Plain', [ast('SoftBreak')])])], result)
  end

  def test_walk_of_hash_of_elements_replacing_some_elements
    filter = PandocFilter.new { |type, value| @types << type; @values << value; ast('LineBreak') if type == 'Null' }
    result = filter.walk('x' => [ast('Space')], 'y' => [ast('SoftBreak')], 'z' => [ast('Null')])
    assert_equal(['Space', 'SoftBreak', 'Null'], @types)
    assert_equal([[], [], []], @values)
    assert_equal({ 'x' => [ast('Space')], 'y' => [ast('SoftBreak')], 'z' => [ast('LineBreak')] }, result)
  end

  def test_walk_and_remove_element
    filter = PandocFilter.new { |type, value| @types << type; @values << value; [] if type == 'Str' }
    result = filter.walk([ast('Para', [ast('Str', 'hello'), ast('Space'), ast('Str', 'world')])])
    assert_equal(['Para', 'Str', 'Space', 'Str'], @types)
    assert_equal([[ast('Str', 'hello'), ast('Space'), ast('Str', 'world')], 'hello', [], 'world'], @values)
    assert_equal([ast('Para', [ast('Space')])], result)
  end

  def test_walk_and_add_elements
    filter = PandocFilter.new { |type, value| @types << type; @values << value; [ast('LineBreak'), ast(type, value)] if type == 'Str' }
    result = filter.walk([ast('Para', [ast('Str', 'hello'), ast('Space'), ast('Str', 'world')])])
    assert_equal(['Para', 'Str', 'Space', 'Str'], @types)
    assert_equal([[ast('Str', 'hello'), ast('Space'), ast('Str', 'world')], 'hello', [], 'world'], @values)
    assert_equal([ast('Para', [ast('LineBreak'), ast('Str', 'hello'), ast('Space'), ast('LineBreak'), ast('Str', 'world')])], result)
  end
end
