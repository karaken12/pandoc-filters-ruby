require 'minitest/autorun'
require 'open3'
require 'stringio'
require_relative '../lib/pandoc-filter'

module PandocHelper
  def ast_to_stream(ast)
    StringIO.new(JSON.dump(ast))
  end

  def stream_to_ast(stream)
    JSON.parse(stream.string)
  end

  def strip_whitespace(str)
    spaces = str[/^ +/]
    str.gsub /^#{spaces}/, ""
  end

  def to_pandoc_ast(markdown, strip: true)
    markdown = strip_whitespace(markdown) if strip
    output, status = Open3.capture2('pandoc -f markdown -t json -s', stdin_data: markdown)
    raise 'Error capturing pandoc output!' unless status.success?
    JSON.parse(output)
  end
end

module PandocAstHelper
  def ast(type, value = [])
    { 't' => type, 'c' => value }
  end

  def hello_str_ast
    ast('Str', 'hello')
  end

  def world_str_ast
    ast('Str', 'world')
  end

  def space_ast
    ast('Space')
  end

  def soft_break_ast
    ast('SoftBreak')
  end

  def line_break_ast
    ast('LineBreak')
  end

  def null_ast
    ast('Null')
  end

  def para_ast(*children)
    ast('Para', children)
  end

  def plain_ast(*children)
    ast('Plain', children)
  end
end

module PandocElementHelper
  def hello_str
    PandocElement::Str.new('hello')
  end

  def world_str
    PandocElement::Str.new('world')
  end

  def space
    PandocElement::Space.new
  end

  def soft_break
    PandocElement::SoftBreak.new
  end

  def line_break
    PandocElement::LineBreak.new
  end

  def null
    PandocElement::Null.new
  end

  def para(*children)
    PandocElement::Para.new(children)
  end

  def plain(*children)
    PandocElement::Plain.new(children)
  end
end
