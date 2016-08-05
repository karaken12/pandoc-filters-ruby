require_relative 'test_helper'

class ChangeAttributesTest < Minitest::Test
  include PandocHelper

  def test_str
    str = PandocElement::Str.new('hello')
    str.value.upcase!
    assert_equal(ast('Str', 'HELLO'), str.to_ast)
    str.value = 'world'
    assert_equal(ast('Str', 'world'), str.to_ast)
  end

  def test_para
    para = PandocElement::Para.new([
      PandocElement::Str.new('hello'),
      PandocElement::Space.new,
      PandocElement::Str.new('world')
    ])

    para.elements.pop
    assert_equal(ast('Para', [ast('Str', 'hello'), ast('Space')]), para.to_ast)
    para.elements = [PandocElement::Str.new('goodnight')]
    assert_equal(ast('Para', [ast('Str', 'goodnight')]), para.to_ast)
  end

  def test_link
    link = PandocElement::Link.new([
      PandocElement::Attr.new(['id', ['class1', 'class2'], [['key1', 'value1'], ['key2', 'value2']]]),
      [PandocElement::Str.new('link')],
      PandocElement::Target.new(['http://example.com', 'This is the title'])
    ])

    link.attributes.identifier = 'new-id'
    assert_equal(ast('Link', [['new-id', ['class1', 'class2'], [['key1', 'value1'], ['key2', 'value2']]], [ast('Str', 'link')], ['http://example.com', 'This is the title']]), link.to_ast)

    link.attributes.classes = ['class1']
    assert_equal(ast('Link', [['new-id', ['class1'], [['key1', 'value1'], ['key2', 'value2']]], [ast('Str', 'link')], ['http://example.com', 'This is the title']]), link.to_ast)

    link.attributes = PandocElement::Attr.new(['new-id', ['class1'], [['key3', 'value3']]])
    assert_equal(ast('Link', [['new-id', ['class1'], [['key3', 'value3']]], [ast('Str', 'link')], ['http://example.com', 'This is the title']]), link.to_ast)

    link.target.url = 'http://alternate-example.com'
    assert_equal(ast('Link', [['new-id', ['class1'], [['key3', 'value3']]], [ast('Str', 'link')], ['http://alternate-example.com', 'This is the title']]), link.to_ast)

    link.target.title = 'New title'
    assert_equal(ast('Link', [['new-id', ['class1'], [['key3', 'value3']]], [ast('Str', 'link')], ['http://alternate-example.com', 'New title']]), link.to_ast)

    link.elements = [PandocElement::Str.new('new-link')]
    assert_equal(ast('Link', [['new-id', ['class1'], [['key3', 'value3']]], [ast('Str', 'new-link')], ['http://alternate-example.com', 'New title']]), link.to_ast)
  end

  def test_attr_attributes_via_attribute_setters
    attr = PandocElement::Attr.new(['id', ['class'], [['key1', 'value1'], ['key2', 'value2']]])
    assert attr.include?('key1')
    refute attr.include?('key3')
    attr.key_values = [['key3', 'value3']]
    assert_equal(['id', ['class'], [['key3', 'value3']]], attr.to_ast)
    refute attr.include?('key1')
    assert attr.include?('key3')
  end

  def test_attr_attributes_via_index_setter_with_missing_key
    attr = PandocElement::Attr.new(['id', ['class'], [['key', 'value']]])
    assert attr.include?('key')
    refute attr.include?('key2')
    attr['key2'] = 'value2'
    assert_equal(['id', ['class'], [['key', 'value'], ['key2', 'value2']]], attr.to_ast)
    assert attr.include?('key')
    assert attr.include?('key2')
  end

  def test_attr_attributes_via_index_setter_with_single_key
    attr = PandocElement::Attr.new(['id', ['class'], [['key', 'value']]])
    assert attr.include?('key')
    attr['key'] = 'value2'
    assert_equal(['id', ['class'], [['key', 'value2']]], attr.to_ast)
    assert attr.include?('key')
  end

  def test_attr_attributes_via_index_setter_with_duplicate_key
    attr = PandocElement::Attr.new(['id', ['class'], [['key', 'value1'], ['key', 'value2']]])
    assert attr.include?('key')
    attr['key'] = 'value3'
    assert_equal(['id', ['class'], [['key', 'value3'], ['key', 'value2']]], attr.to_ast)
    assert attr.include?('key')
  end
end
