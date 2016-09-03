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
    JSON.parse pandoc(markdown, to: "json")
  end

  def pandoc(content, filter: nil, from: "markdown", to: "markdown", strip: true, standalone: true)
    content = strip_whitespace(content) if strip
    options = ["-f #{from}", "-t #{to}"]
    options << "-s" if standalone
    options << "--filter '#{filter}'" if filter
    output, status = Open3.capture2({ "RUBYLIB" => File.expand_path("../../lib", __FILE__)}, "pandoc #{options.join(" ")}", stdin_data: content)
    raise 'Error capturing pandoc output!' unless status.success?
    output
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
