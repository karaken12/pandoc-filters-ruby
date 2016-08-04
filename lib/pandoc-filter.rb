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
  [ ['Plain', 1],
    ['Para', 1],
    ['CodeBlock', 2],
    ['RawBlock', 2],
    ['BlockQuote', 1],
    ['OrderedList', 2],
    ['BulletList', 1],
    ['DefinitionList', 1],
    ['Header', 3],
    ['HorizontalRule', 0],
    ['Table', 5],
    ['Div', 2],
    ['Null', 0],
    ['Str', 1],
    ['Emph', 1],
    ['Strong', 1],
    ['Strikeout', 1],
    ['Superscript', 1],
    ['Subscript', 1],
    ['SmallCaps', 1],
    ['Quoted', 2],
    ['Cite', 2],
    ['Code', 2],
    ['Space', 0],
    ['SoftBreak', 0],
    ['LineBreak', 0],
    ['Math', 2],
    ['RawInline', 2],
    ['Link', 3],
    ['Image', 3],
    ['Note', 1],
    ['Span', 2]
  ].each do |name, params|
    if params == 0
      define_singleton_method(name) { {'t'=>name, 'c'=>[]} }
    elsif params == 1
      define_singleton_method(name) { |value| {'t'=>name, 'c'=>value} }
    elsif params == 2
      define_singleton_method(name) { |v1,v2| {'t'=>name, 'c'=>[v1,v2]} }
    elsif params == 3
      define_singleton_method(name) { |v1,v2,v3| {'t'=>name, 'c'=>[v1,v2,v3]} }
    elsif params == 4
      define_singleton_method(name) { |v1,v2,v3,v4| {'t'=>name, 'c'=>[v1,v2,v3,v4]} }
    elsif params == 5
      define_singleton_method(name) { |v1,v2,v3,v4,v5| {'t'=>name, 'c'=>[v1,v2,v3i,v4,v5]} }
    else
      puts "Error!"
    end
  end
end
