require_relative 'test_helper'

class MetaTest < Minitest::Test
  include PandocAstHelper
  include PandocHelper

  def test_null
    object = PandocElement::Document.new to_pandoc_ast(<<-EOF)
      Contents
    EOF

    assert_equal PandocElement::Meta, object.meta.class
    expected_ast = { 'unMeta' => {} }
    assert_equal expected_ast, object.meta.to_ast
  end

  def test_empty
    object = PandocElement::Document.new to_pandoc_ast(<<-EOF)
      ---
      ---
      Contents
    EOF

    assert_equal PandocElement::Meta, object.meta.class
    expected_ast = { 'unMeta' => {} }
    assert_equal expected_ast, object.meta.to_ast
  end

  def test_string
    object = PandocElement::Document.new to_pandoc_ast(<<-EOF)
      ---
      key: 123
      ---
      Contents
    EOF

    assert_equal PandocElement::MetaString, object.meta['key'].class
    expected_ast = { 'unMeta' => { 'key' => ast('MetaString', '123') } }
    assert_equal expected_ast, object.meta.to_ast
  end

  def test_bool
    object = PandocElement::Document.new to_pandoc_ast(<<-EOF)
      ---
      key: true
      ---
      Contents
    EOF

    assert_equal PandocElement::MetaBool, object.meta['key'].class
    expected_ast = { 'unMeta' => { 'key' => ast('MetaBool', true) } }
    assert_equal expected_ast, object.meta.to_ast
  end

  def test_list
    object = PandocElement::Document.new to_pandoc_ast(<<-EOF)
      ---
      key:
      - 123
      - 456
      ---
      Contents
    EOF

    assert_equal PandocElement::MetaList, object.meta['key'].class
    expected_ast = { 'unMeta' => { 'key' => ast('MetaList', [ast('MetaString', '123'), ast('MetaString', '456')]) } }
    assert_equal expected_ast, object.meta.to_ast
  end

  def test_map
    object = PandocElement::Document.new to_pandoc_ast(<<-EOF)
      ---
      key:
        key1: 123
        key2: 456
      ---
      Contents
    EOF

    assert_equal PandocElement::MetaMap, object.meta['key'].class
    expected_ast = { 'unMeta' => { 'key' => ast('MetaMap', { 'key1' => ast('MetaString', '123'), 'key2' => ast('MetaString', '456') }) } }
    assert_equal expected_ast, object.meta.to_ast
  end

  def test_inlines
    object = PandocElement::Document.new to_pandoc_ast(<<-EOF)
      ---
      key: hello world
      ---
      Contents
    EOF

    assert_equal PandocElement::MetaInlines, object.meta['key'].class
    expected_ast = { 'unMeta' => { 'key' => ast('MetaInlines', [ast('Str', 'hello'), ast('Space'), ast('Str', 'world')]) } }
    assert_equal expected_ast, object.meta.to_ast
  end

  def test_blocks
    object = PandocElement::Document.new to_pandoc_ast(<<-EOF)
      ---
      key: |
          <p>
          Contents
          </p>
      ---
      Contents
    EOF

    assert_equal PandocElement::MetaBlocks, object.meta['key'].class
    expected_ast = { 'unMeta' => { 'key' => ast('MetaBlocks', [ast('RawBlock', ['html', '<p>']), ast('Plain', [ast('Str', 'Contents')]), ast('RawBlock', ['html', '</p>'])]) } }
    assert_equal expected_ast, object.meta.to_ast
  end
end
