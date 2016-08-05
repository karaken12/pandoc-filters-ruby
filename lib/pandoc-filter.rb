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

  def self.to_object(object)
    if object.kind_of?(Array)
      object.map { |x| to_object(x) }
    elsif object.kind_of?(Hash) && object.include?('t') && object.include?('c')
      raise "Unknown type: #{object['t']}" unless PandocElement.const_defined?(object['t'])
      type = PandocElement.const_get(object['t'])
      raise "Invalid type: #{object['t']}" unless type < PandocElement::BaseElement
      type.new(to_object(object['c']))
    elsif object.kind_of?(Hash)
      result = {}
      object.each { |key, value| result[key] = to_object(value) }
      result
    else
      object
    end
  end

  class Base
    attr_reader :contents

    def self.contents_attr(name, index)
      define_method(name) { contents[index] }
    end

    def initialize(contents = [])
      @contents = contents
    end

    def to_ast
      PandocElement.to_ast(contents)
    end

    def ==(other)
      self.class == other.class && contents == other.contents
    end
  end

  class BaseElement < PandocElement::Base
    def to_ast
      { 't' => element_name, 'c' => PandocElement.to_ast(contents) }
    end
  end

  module Inline
  end

  module Block
  end

  class Attr < PandocElement::Base
    contents_attr :identifier, 0
    contents_attr :classes, 1
    contents_attr :key_values, 2

    def [](key)
      key_values_hash[key]
    end

    def include?(key)
      key_values_hash.include?(key)
    end

    private

    def key_values_hash
      @key_values_hash ||= Hash[key_values]
    end
  end

  class Target < PandocElement::Base
    contents_attr :url, 0
    contents_attr :title, 1
  end

  [ ['Plain',          :elements,                                        { include: [PandocElement::Block] }],
    ['Para',           :elements,                                        { include: [PandocElement::Block] }],
    ['CodeBlock',      :attributes, :value,                              { include: [PandocElement::Block] }],
    ['RawBlock',       :format, :value,                                  { include: [PandocElement::Block] }],
    ['BlockQuote',     :elements,                                        { include: [PandocElement::Block] }],
    ['OrderedList',    :attributes, :elements,                           { include: [PandocElement::Block] }],
    ['BulletList',     :elements,                                        { include: [PandocElement::Block] }],
    ['DefinitionList', :elements,                                        { include: [PandocElement::Block] }],
    ['Header',         :level, :attributes, :elements,                   { include: [PandocElement::Block] }],
    ['HorizontalRule',                                                   { include: [PandocElement::Block] }],
    ['Table',          :captions, :alignments, :widths, :headers, :rows, { include: [PandocElement::Block] }],
    ['Div',            :attributes, :elements,                           { include: [PandocElement::Block] }],
    ['Null',                                                             { include: [PandocElement::Block] }],
    ['Str',            :value,                                           { include: [PandocElement::Inline] }],
    ['Emph',           :elements,                                        { include: [PandocElement::Inline] }],
    ['Strong',         :elements,                                        { include: [PandocElement::Inline] }],
    ['Strikeout',      :elements,                                        { include: [PandocElement::Inline] }],
    ['Superscript',    :elements,                                        { include: [PandocElement::Inline] }],
    ['Subscript',      :elements,                                        { include: [PandocElement::Inline] }],
    ['SmallCaps',      :elements,                                        { include: [PandocElement::Inline] }],
    ['Quoted',         :type, :elements,                                 { include: [PandocElement::Inline] }],
    ['Cite',           :citations, :elements,                            { include: [PandocElement::Inline] }],
    ['Code',           :attributes, :value,                              { include: [PandocElement::Inline] }],
    ['Space',                                                            { include: [PandocElement::Inline] }],
    ['SoftBreak',                                                        { include: [PandocElement::Inline] }],
    ['LineBreak',                                                        { include: [PandocElement::Inline] }],
    ['Math',           :type, :value,                                    { include: [PandocElement::Inline] }],
    ['RawInline',      :format, :value,                                  { include: [PandocElement::Inline] }],
    ['Link',           :attributes, :elements, :target,                  { include: [PandocElement::Inline] }],
    ['Image',          :attributes, :elements, :target,                  { include: [PandocElement::Inline] }],
    ['Note',           :elements,                                        { include: [PandocElement::Inline] }],
    ['Span',           :attributes, :elements,                           { include: [PandocElement::Inline] }]
  ].each do |name, *params|
    name.freeze

    options = if params.last.kind_of?(Hash)
      params.pop
    else
      {}
    end

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

    const_set(name, Class.new(PandocElement::BaseElement) {
      (options[:include] || []).each { |mod| include mod }

      if params.size == 1
        define_method(params.first) { contents }
      else
        params.each_with_index { |param, index| contents_attr param, index }
      end

      define_method(:element_name) { name }
    })
  end
end
