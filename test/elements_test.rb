require_relative 'test_helper'

class ElementsTest < Minitest::Test
  def test_space
    space = PandocElement::Space.new
    assert_equal([], space.contents)
    assert space.kind_of?(PandocElement::Inline)
  end

  def test_str
    str = PandocElement::Str.new('hello')
    assert_equal('hello', str.contents)
    assert_equal('hello', str.value)
    assert str.kind_of?(PandocElement::Inline)
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
    assert para.kind_of?(PandocElement::Block)
  end

  def test_link
    link = PandocElement::Link.new([
      PandocElement::Attr.new(['id', ['class1', 'class2'], [['key1', 'value1'], ['key2', 'value2']]]),
      [PandocElement::Str.new('link')],
      PandocElement::Target.new(['http://example.com', 'This is the title'])
    ])

    assert_equal('id', link.attributes.identifier)
    assert_equal(['class1', 'class2'], link.attributes.classes)
    assert_equal([['key1', 'value1'], ['key2', 'value2']], link.attributes.key_values)
    assert_equal('value1', link.attributes['key1'])
    assert_equal('value2', link.attributes['key2'])
    assert_equal(nil, link.attributes['key3'])
    assert_equal(true, link.attributes.include?('key1'))
    assert_equal(true, link.attributes.include?('key2'))
    assert_equal(false, link.attributes.include?('key3'))
    assert_equal([PandocElement::Str.new('link')], link.elements)
    assert_equal('http://example.com', link.target.url)
    assert_equal('This is the title', link.target.title)
  end
end
