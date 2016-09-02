#!/usr/bin/env ruby

require 'pandoc-filter'

def self.tobullet(term, defs)
  elements = [ PandocElement::Para.new([PandocElement::Strong.new(term)]) ]
  defs.each do |el|
    el.each do |el_el|
      elements.push(el_el)
    end
  end
  return elements
end

def self.bullet_list(items)
  items = items.map{|item| tobullet(item[0],item[1])}
  PandocElement::BulletList.new(items)
end

PandocElement.filter! do |element|
  if element.kind_of?(PandocElement::DefinitionList)
    bullet_list(element.elements)
  end
end
