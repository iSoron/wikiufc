class Fixnum
	def is_numeric?
		true
	end
end

class String
	def is_numeric?
		Float self rescue false
	end

	#def html_escape
	#	ERB::Util::html_escape(self)
	#end

	#%w[auto_link excerpt highlight sanitize simple_format strip_tags truncate word_wrap].each do |method|
	#	eval "def #{method}(*args); ActionController::Base.helpers.#{method}(self, *args); end"
	#end

	def pretty_url
		self.mb_chars.normalize(:kd).
			gsub(/[^\x00-\x7F]/n,'').
			gsub(/[^a-z._0-9 -]/i,"").
			gsub(/ +/,"_").
			downcase.to_s
	end
end

#class Array
#  def add_condition! (condition, conjunction = 'AND')
#    if String === condition
#      add_condition!([condition])
#    elsif Hash === condition
#      add_condition!([condition.keys.map { |attr| "#{attr}=?" }.join(' AND ')] + condition.values)
#    elsif Array === condition
#      self[0] = "(#{self[0]}) #{conjunction} (#{condition.shift})" unless empty?
#      (self << condition).flatten!
#    else
#      raise "don't know how to handle this condition type"
#    end
#    self
#  end
#end

#module ActiveRecord
#  module Acts
#    module Versioned
#      module ClassMethods
#        def acts_as_paranoid_versioned
#          # protect the versioned model
#          self.versioned_class.class_eval do
#            def self.delete_all(conditions = nil); return; end
#          end
#        end
#      end
#    end
#  end
#end

# disable XSS protection
module CustomHtmlSafe
  def html_safe?
    true
  end
end
 
class ActionView::OutputBuffer
  include CustomHtmlSafe
end
class ActionView::SafeBuffer
  include CustomHtmlSafe
end
class String
  include CustomHtmlSafe
end
