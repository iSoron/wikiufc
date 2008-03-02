require 'gibberish/localize'
require 'gibberish/string_ext'
require 'gibberish/activerecord_ext'

String.send :include, Gibberish::StringExt

module Gibberish
  extend Localize
end

