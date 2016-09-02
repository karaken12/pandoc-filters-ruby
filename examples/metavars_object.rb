#!/usr/bin/env ruby

# Pandoc filter to allow interpolation of metadata fields
# into a document.  %{fields} will be replaced by the field's
# value, assuming it is of the type MetaInlines or MetaString.

require 'pandoc-filter'

PandocElement.filter do |element|
  if element.kind_of?(PandocElement::Str)
    match = /%\{(.*)\}$/.match(element.value)

    if match
      field = match[1]
      result = meta[field]

      if result['t'] == 'MetaInlines'
        next PandocElement.Span(['', ['interpolated'], [['field', field]]], result['c'])
      elsif result['t'] == 'MetaString'
        next PandocElement.Str(result['c'])
      end
    end
  end
end
