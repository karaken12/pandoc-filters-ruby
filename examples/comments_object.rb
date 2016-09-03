#!/usr/bin/env ruby

require 'pandoc-filter'

incomment = false

PandocElement.filter! do |element|
  if element.kind_of?(PandocElement::RawBlock)
    if element.format == 'html'
      if /<!-- BEGIN COMMENT -->/.match(element.value)
        incomment = true
        next []
      elsif /<!-- END COMMENT -->/.match(element.value)
        incomment = false
        next []
      end
    end
  end

  next [] if incomment
end
