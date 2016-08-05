require 'minitest/autorun'
require 'open3'
require 'stringio'
require_relative '../lib/pandoc-filter'

module PandocHelper
  def ast(type, value = [])
    { 't' => type, 'c' => value }
  end


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
