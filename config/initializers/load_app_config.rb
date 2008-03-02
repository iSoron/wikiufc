require 'ostruct'
::App = OpenStruct.new

# Define os campos essenciais
required_fields = %w(
	title
	language
	max_upload_file_size
	default_color
)

# Carrega as configuracoes personalizadas
require "#{RAILS_ROOT}/config/application.rb"

# Verifica se todas os campos essenciais foram instanciados
required_fields.each do |field|
	raise "Required configuration not found: App.#{field}" unless App.respond_to?(field)
end

# Internacionalizacao
Gibberish.current_language = App.language if RAILS_ENV != 'test'
