# Copyright (c) Tom Potts, 2015
# Inspired by Python code by John MacFarlane.
# See http://pandoc.org/scripting.html
# and https://github.com/jgm/pandocfilters
# for more information.

require 'json'

module PandocFilter

  def self.filter(input = $stdin, output = $stdout, &block)
    # maybe not the right call?
    doc = JSON.parse(input.read)
    format = nil
    if ARGV.length > 1
      @format = ARGV[1]
    end
    @block = block
    @meta = doc[0]['unMeta']
    output.puts JSON.dump(walk(doc))
  end

  def self.walk(x)
    if x.kind_of?(Array)
      result = []
      x.each do |item|
        if item.kind_of?(Hash) && item.has_key?('t')
          res = @block.call(item['t'], item['c'], @format, @meta)
          if !res
            result.push(walk(item))
          elsif res.kind_of?(Array)
            res.each do |z|
              result.push(walk(z))
            end
          else
            result.push(walk(res))
          end
        else
          result.push(walk(item))
        end
      end
      return result
    elsif x.kind_of?(Hash)
      result = {}
      x.each do |key,value|
        result[key] = walk(value)
      end
      return result
    else
      return x
    end
  end

end

module PandocElement
  def self.to_ast(object)
    if object.respond_to?(:to_ast)
      object.to_ast
    elsif object.kind_of?(Array)
      object.map { |x| to_ast(x) }
    elsif object.kind_of?(Hash)
      result = {}
      object.each { |key, value| result[key] = to_ast(value) }
      result
    else
      object
    end
  end

  class Base
    attr_reader :contents

    def initialize(contents = [])
      @contents = contents
    end

    def to_ast
      { 't' => element_name, 'c' => PandocElement.to_ast(contents) }
    end
  end

  [ ['Plain', :elements],
    ['Para', :elements],
    ['CodeBlock', :attributes, :value],
    ['RawBlock', :format, :value],
    ['BlockQuote', :elements],
    ['OrderedList', :attributes, :elements],
    ['BulletList', :elements],
    ['DefinitionList', :elements],
    ['Header', :level, :attributes, :elements],
    ['HorizontalRule'],
    ['Table', :captions, :alignments, :widths, :headers, :rows],
    ['Div', :attributes, :elements],
    ['Null'],
    ['Str', :value],
    ['Emph', :elements],
    ['Strong', :elements],
    ['Strikeout', :elements],
    ['Superscript', :elements],
    ['Subscript', :elements],
    ['SmallCaps', :elements],
    ['Quoted', :type, :elements],
    ['Cite', :citations, :elements],
    ['Code', :attributes, :value],
    ['Space'],
    ['SoftBreak'],
    ['LineBreak'],
    ['Math', :type, :value],
    ['RawInline', :format, :value],
    ['Link', :attributes, :elements, :target],
    ['Image', :attributes, :elements, :target],
    ['Note', :elements],
    ['Span', :attributes, :elements]
  ].each do |name, *params|
    case params.size
    when 0
      define_singleton_method(name) { {'t'=>name, 'c'=>[]} }
    when 1
      define_singleton_method(name) { |value| {'t'=>name, 'c'=>value} }
    when 2
      define_singleton_method(name) { |v1,v2| {'t'=>name, 'c'=>[v1,v2]} }
    when 3
      define_singleton_method(name) { |v1,v2,v3| {'t'=>name, 'c'=>[v1,v2,v3]} }
    when 4
      define_singleton_method(name) { |v1,v2,v3,v4| {'t'=>name, 'c'=>[v1,v2,v3,v4]} }
    when 5
      define_singleton_method(name) { |v1,v2,v3,v4,v5| {'t'=>name, 'c'=>[v1,v2,v3i,v4,v5]} }
    else
      raise "Too many parameters!"
    end

    const_set(name, Class.new(PandocElement::Base) {
      if params.size == 1
        define_method(params.first) { contents }
      else
        params.each_with_index { |param, index| define_method(param) { contents[index] } }
      end

      define_method(:element_name) { name }
    })
  end
end
