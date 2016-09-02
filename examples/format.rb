#!/usr/bin/env ruby

# Pandoc filter to allow inserting the format that the document was formatted
# to. %{format} will be replaced by the format that pandoc passes in to this
# filter. It will only be replaced from matching Str elements.

require 'pandoc-filter'

PandocFilter.filter do |type,value,format,meta|
  if type == 'Str' && value == '%{format}'
    PandocElement.Str(format)
  end
end
