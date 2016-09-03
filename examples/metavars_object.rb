#!/usr/bin/env ruby

# Pandoc filter to allow interpolation of metadata fields
# into a document.  %{fields} will be replaced by the field's
# value, assuming it is of the type MetaInlines or MetaString.

require 'pandoc-filter'

filter = PandocElement::Filter.new

filter.filter! do |element|
  if element.kind_of?(PandocElement::Str)
    match = /%\{(.*)\}$/.match(element.value)

    if match
      field = match[1]
      result = filter.meta[field]

      if result.kind_of?(PandocElement::MetaInlines)
        next PandocElement::Span.new([PandocElement::Attr.build(classes: ['interpolated'], key_values: { 'field' => field }), result.elements])
      elsif result.kind_of?(PandocElement::MetaString)
        next PandocElement.Str(result.value)
      end
    end
  end
end
