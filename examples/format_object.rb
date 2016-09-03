#!/usr/bin/env ruby

# Pandoc filter to allow inserting the format that the document was formatted
# to. %{format} will be replaced by the format that pandoc passes in to this
# filter. It will only be replaced from matching Str elements.

require 'pandoc-filter'

filter = PandocElement::Filter.new

filter.filter do |element|
  if element.kind_of?(PandocElement::Str) && element.value == '%{format}'
    element.value = filter.format
  end
end
