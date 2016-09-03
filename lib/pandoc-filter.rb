# Copyright (c) Tom Potts, 2015
# Inspired by Python code by John MacFarlane.
# See http://pandoc.org/scripting.html
# and https://github.com/jgm/pandocfilters
# for more information.

require 'json'

class PandocFilter
  attr_accessor :format, :meta

  def initialize(input = $stdin, output = $stdout, argv = ARGV, &block)
    @input = input
    @output = output
    @argv = argv
    @block = block
  end

  def self.filter(input = $stdin, output = $stdout, argv = ARGV, &block)
    new(input, output, argv, &block).filter
  end

  def filter
    doc = JSON.parse(@input.read)
    @format = @argv.first
    @meta = doc[0]['unMeta']
    @output.puts JSON.dump(walk(doc))
  end

  def walk(x)
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
    elsif object.kind_of?(Hash) && object.include?('unMeta')
      PandocElement::Meta.new(to_object(object['unMeta']))
    elsif object.kind_of?(Hash)
      result = {}
      object.each { |key, value| result[key] = to_object(value) }
      result
    else
      object
    end
  end

  def self.walk(object, &block)
    PandocElement::Walker.new(object, &block).walk
  end

  def self.walk!(object, &block)
    PandocElement::Walker.new(object, &block).walk!
  end

  def self.filter(input = $stdin, output = $stdout, argv = ARGV, &block)
    PandocElement::Filter.new(input, output, argv, &block).filter
  end

  def self.filter!(input = $stdin, output = $stdout, argv = ARGV, &block)
    PandocElement::Filter.new(input, output, argv, &block).filter!
  end

  class Filter
    attr_accessor :doc, :format, :meta

    def initialize(input = $stdin, output = $stdout, argv = ARGV, &block)
      @input = input
      @output = output
      @argv = argv
      @block = block
    end

    def filter(&block)
      process(block) do
        PandocElement.walk(@doc, &@block)
        @doc
      end
    end

    def filter!(&block)
      process(block) { PandocElement.walk!(@doc, &@block) }
    end

    private

    def process(block)
      @block = block unless @block
      @doc = PandocElement::Document.new(JSON.parse(@input.read))
      @format = @argv.first
      @meta = @doc.meta
      result = yield
      @output.puts JSON.dump(PandocElement.to_ast(result))
    end
  end

  class Walker
    def initialize(object, &block)
      @object = object
      @block = block
    end

    def walk(object = @object)
      if object.kind_of?(Array)
        object.each do |item|
          if item.kind_of?(PandocElement::BaseElement)
            @block.call(item)
          end

          walk(item)
        end
      elsif object.kind_of?(Hash)
        object.values.each do |value|
          walk(value)
        end
      elsif object.kind_of?(PandocElement::Base)
        walk(object.contents)
      end

      object
    end

    def walk!(object = @object)
      if object.kind_of?(Array)
        result = []
        object.each do |item|
          if item.kind_of?(PandocElement::BaseElement)
            res = @block.call(item)
            if !res
              result.push(walk!(item))
            elsif res.kind_of?(Array)
              res.each do |z|
                result.push(walk!(z))
              end
            else
              result.push(walk!(res))
            end
          else
            result.push(walk!(item))
          end
        end
        return result
      elsif object.kind_of?(Hash)
        result = {}
        object.each do |key, value|
          result[key] = walk!(value)
        end
        return result
      elsif object.kind_of?(PandocElement::Base)
        object.contents = walk!(object.contents)
        return object
      else
        return object
      end
    end
  end

  class Base
    attr_accessor :contents

    def self.contents_attr(name, index = nil)
      if index
        define_method(name) { contents[index] }
        define_method("#{name}=") { |value| contents[index] = value }
      else
        define_method(name) { contents }
        define_method("#{name}=") { |value| @contents = value }
      end
    end

    def initialize(contents = [])
      @contents = contents
      convert_contents if respond_to?(:convert_contents, true)
    end

    def to_ast
      PandocElement.to_ast(contents)
    end

    def inspect
      to_ast.inspect
    end

    def ==(other)
      self.class == other.class && contents == other.contents
    end

    def walk(&block)
      PandocElement.walk(self, &block)
    end

    def walk!(&block)
      PandocElement.walk!(self, &block)
    end
  end

  class BaseElement < PandocElement::Base
    def to_ast
      { 't' => element_name, 'c' => PandocElement.to_ast(contents) }
    end
  end

  module Enum
    def [](key)
      elements[key]
    end

    def []=(key, value)
      elements[key] = value
    end
  end

  module MetaValue
  end

  module Inline
  end

  module Block
  end

  class Document < PandocElement::Base
    attr_reader :meta

    def initialize(ast)
      object = PandocElement.to_object(ast)
      @meta = object[0]
      @contents = object[1]
    end

    def to_ast
      [meta.to_ast, PandocElement.to_ast(contents)]
    end
  end

  class Meta < PandocElement::Base
    include PandocElement::Enum
    alias_method :elements, :contents

    def initialize(contents = {})
      super
    end

    def to_ast
      { 'unMeta' => PandocElement.to_ast(contents) }
    end
  end

  class Attr < PandocElement::Base
    contents_attr :identifier, 0
    contents_attr :classes, 1
    contents_attr :key_values, 2

    def self.build(options = {})
      id = options.fetch(:identifier, '')
      classes = options.fetch(:classes, [])
      key_values = options.fetch(:key_values, [])

      if key_values.kind_of?(Hash)
        key_values = key_values.to_a
      end

      new([id, classes, key_values])
    end

    def [](key)
      # NOTE: While this pseudo Hash implementations are inefficient, they
      # guarantee any changes to key_values will be honored, which would be
      # difficult if the key_values were cached in a Hash
      result = key_values.find { |pair| pair.first == key } || []
      result[1]
    end

    def []=(key, value)
      found = key_values.find { |pair| pair.first == key }

      if found
        found[1] = value
      else
        key_values << [key, value]
      end
    end

    def include?(key)
      !!key_values.find { |pair| pair.first == key }
    end
  end

  class Target < PandocElement::Base
    contents_attr :url, 0
    contents_attr :title, 1
  end

  [ ['MetaMap',        :elements,                                        { include: [PandocElement::MetaValue, PandocElement::Enum] }],
    ['MetaList',       :elements,                                        { include: [PandocElement::MetaValue, PandocElement::Enum] }],
    ['MetaBool',       :value,                                           { include: [PandocElement::MetaValue] }],
    ['MetaString',     :value,                                           { include: [PandocElement::MetaValue] }],
    ['MetaInlines',    :elements,                                        { include: [PandocElement::MetaValue, PandocElement::Enum] }],
    ['MetaBlocks',     :elements,                                        { include: [PandocElement::MetaValue, PandocElement::Enum] }],
    ['Plain',          :elements,                                        { include: [PandocElement::Block, PandocElement::Enum] }],
    ['Para',           :elements,                                        { include: [PandocElement::Block, PandocElement::Enum] }],
    ['CodeBlock',      :attributes, :value,                              { include: [PandocElement::Block], conversions: { attributes: PandocElement::Attr } }],
    ['RawBlock',       :format, :value,                                  { include: [PandocElement::Block] }],
    ['BlockQuote',     :elements,                                        { include: [PandocElement::Block, PandocElement::Enum] }],
    ['OrderedList',    :attributes, :elements,                           { include: [PandocElement::Block, PandocElement::Enum] }],
    ['BulletList',     :elements,                                        { include: [PandocElement::Block, PandocElement::Enum] }],
    ['DefinitionList', :elements,                                        { include: [PandocElement::Block, PandocElement::Enum] }],
    ['Header',         :level, :attributes, :elements,                   { include: [PandocElement::Block, PandocElement::Enum], conversions: { attributes: PandocElement::Attr } }],
    ['HorizontalRule',                                                   { include: [PandocElement::Block] }],
    ['Table',          :captions, :alignments, :widths, :headers, :rows, { include: [PandocElement::Block] }],
    ['Div',            :attributes, :elements,                           { include: [PandocElement::Block, PandocElement::Enum], conversions: { attributes: PandocElement::Attr } }],
    ['Null',                                                             { include: [PandocElement::Block] }],
    ['Str',            :value,                                           { include: [PandocElement::Inline] }],
    ['Emph',           :elements,                                        { include: [PandocElement::Inline, PandocElement::Enum] }],
    ['Strong',         :elements,                                        { include: [PandocElement::Inline, PandocElement::Enum] }],
    ['Strikeout',      :elements,                                        { include: [PandocElement::Inline, PandocElement::Enum] }],
    ['Superscript',    :elements,                                        { include: [PandocElement::Inline, PandocElement::Enum] }],
    ['Subscript',      :elements,                                        { include: [PandocElement::Inline, PandocElement::Enum] }],
    ['SmallCaps',      :elements,                                        { include: [PandocElement::Inline, PandocElement::Enum] }],
    ['Quoted',         :type, :elements,                                 { include: [PandocElement::Inline, PandocElement::Enum] }],
    ['Cite',           :citations, :elements,                            { include: [PandocElement::Inline, PandocElement::Enum] }],
    ['Code',           :attributes, :value,                              { include: [PandocElement::Inline], conversions: { attributes: PandocElement::Attr } }],
    ['Space',                                                            { include: [PandocElement::Inline] }],
    ['SoftBreak',                                                        { include: [PandocElement::Inline] }],
    ['LineBreak',                                                        { include: [PandocElement::Inline] }],
    ['Math',           :type, :value,                                    { include: [PandocElement::Inline] }],
    ['RawInline',      :format, :value,                                  { include: [PandocElement::Inline] }],
    ['Link',           :attributes, :elements, :target,                  { include: [PandocElement::Inline, PandocElement::Enum], conversions: { attributes: PandocElement::Attr, target: PandocElement::Target } }],
    ['Image',          :attributes, :elements, :target,                  { include: [PandocElement::Inline, PandocElement::Enum], conversions: { attributes: PandocElement::Attr, target: PandocElement::Target } }],
    ['Note',           :elements,                                        { include: [PandocElement::Inline, PandocElement::Enum] }],
    ['Span',           :attributes, :elements,                           { include: [PandocElement::Inline, PandocElement::Enum], conversions: { attributes: PandocElement::Attr } }]
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
        contents_attr params.first
      else
        params.each_with_index { |param, index| contents_attr param, index }
      end

      define_method(:element_name) { name }

      if options[:conversions]
        private

        define_method(:convert_contents) do
          @contents = @contents.map.with_index do |x, index|
            convert_to_type = options[:conversions][params[index]]

            if convert_to_type && !x.kind_of?(convert_to_type)
              convert_to_type.new(x)
            else
              x
            end
          end
        end
      end
    })
  end
end
