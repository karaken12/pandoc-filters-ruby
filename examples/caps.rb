#!/usr/bin/env ruby

require 'pandoc-filter'

# Pandoc filter to convert all regular text to uppercase.
# Code, link URLs, etc. are not affected.

PandocFilter.filter do |key, value, format, meta|
  if key == 'Str'
    PandocElement.Str(value.upcase)
  end
end
