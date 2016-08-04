require_relative 'test_helper'

class ElementsTest < Minitest::Test
  def test_space
    space = PandocElement::Space.new
    assert_equal([], space.contents)
  end

  def test_str
    str = PandocElement::Str.new('hello')
    assert_equal('hello', str.contents)
    assert_equal('hello', str.value)
  end

  def test_para
    elements = [
      PandocElement::Str.new('hello'),
      PandocElement::Space.new,
      PandocElement::Str.new('world')
    ]

    para = PandocElement::Para.new(elements)
    assert_equal(elements, para.contents)
    assert_equal(elements, para.elements)
  end
end
