#!/usr/bin/env ruby

require 'pandoc-filter'

# Pandoc filter to convert all regular text to uppercase.
# Code, link URLs, etc. are not affected.

PandocElement.filter do |element|
  if element.kind_of?(PandocElement::Str)
    element.value.upcase!
  end
end
