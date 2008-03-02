# Carrega as classes Message e LogEntry. O lazy loading do Rails gera
# problemas se voce definir varias classes por arquivos.
require "app/models/message.rb"
require "app/models/log_entry.rb"

class String
	def is_numeric?
		Float self rescue false
	end
end
