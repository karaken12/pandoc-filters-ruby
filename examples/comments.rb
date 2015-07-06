#!/usr/bin/env ruby

require 'pandoc-filter'

class CommentFilter
  @incomment = false

  def comment(key, value, format, meta)
    if key == 'RawBlock'
      fmt = value[0]
      s = value[1]
      if fmt == 'html'
        if /<!-- BEGIN COMMENT -->/.match(s)
          @incomment = true
          return []
        elsif /<!-- END COMMENT -->/.match(s)
          @incomment = false
          return []
        end
      end
    end
    if @incomment
      # Supress anything in a comment
      return []
    end
  end
end

filter = CommentFilter.new

PandocFilter.filter do |key,value,format,meta|
  filter.comment(key,value,format,meta)
end
