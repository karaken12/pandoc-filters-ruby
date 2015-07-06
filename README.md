# Pandoc Filter
A small Ruby library to make creating Pandoc filters simpler.

This library is inspired by the similar [Python libray](https://github.com/jgm/pandocfilters).

## Installing
Get the [Ruby Gem](https://rubygems.org/gems/pandoc-filter) by running
`gem install pandoc-filter`.

## Using Pandoc Filter
The basic method is to call `PandocFilter.filter` with a block containing
what you want to do with each AST element. To return a new Pandoc element,
use PandocElement to construct them.

The best way to see this is to check out the
[examples](https://github.com/karaken12/pandoc-filters-ruby/tree/master/examples).
