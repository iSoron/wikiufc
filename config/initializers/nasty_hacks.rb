# Carrega as classes Message e LogEntry. O lazy loading do Rails gera
# problemas se voce definir varias classes por arquivos.
require "#{RAILS_ROOT}/app/models/message.rb"
require "#{RAILS_ROOT}/app/models/log_entry.rb"

class Fixnum
	def is_numeric?
		true
	end
end

class String
	def is_numeric?
		Float self rescue false
	end
end

class Array
  def add_condition! (condition, conjunction = 'AND')
    if String === condition
      add_condition!([condition])
    elsif Hash === condition
      add_condition!([condition.keys.map { |attr| "#{attr}=?" }.join(' AND ')] + condition.values)
    elsif Array === condition
      self[0] = "(#{self[0]}) #{conjunction} (#{condition.shift})" unless empty?
      (self << condition).flatten!
    else
      raise "don't know how to handle this condition type"
    end
    self
  end
end

module ActiveRecord
  module Acts
    module Versioned
      module ClassMethods
        def acts_as_paranoid_versioned
          acts_as_paranoid
          acts_as_versioned      

          # protect the versioned model
          self.versioned_class.class_eval do
            def self.delete_all(conditions = nil); return; end
          end
        end
      end
    end
  end
end
