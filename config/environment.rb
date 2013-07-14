# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
WikiUFC::Application.initialize!
#
# Carrega as classes Message e LogEntry. O lazy loading do Rails gera
# problemas se voce definir varias classes por arquivos.
require "./app/models/message.rb"
require "./app/models/log_entry.rb"
