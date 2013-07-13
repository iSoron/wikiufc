require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'lib/nasty_hacks.rb'
require 'active_support/core_ext/numeric/bytes'

if defined?(Bundler)
  Bundler.require(*Rails.groups(:assets => %w(development test)))
end

module WikiUFC
  class Application < Rails::Application
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.active_support.escape_html_entities_in_json = true
    config.active_record.whitelist_attributes = true
    config.assets.version = '1.0'
    config.assets.enabled = true

    config.language = "pt_BR"
    config.title = "Wiki UFC"
    config.webmaster_email = "webmaster@wikiufc.gelsol.org"

    config.default_host = "localhost:3000"
    config.base_path = ""

    config.current_period = "2009.2"

    # Limites
    config.max_upload_file_size = 5.megabytes

    # Forum
    #config.forum_uri = "http://127.0.0.1:3001/"

    # Tema
    config.default_color = 0
    config.default_avatar = "http://isoron.org/avatar"
    config.color_schemes = [
        # Default
        [ "#037", "#069", "#455", "#778" ],

        # Legado
        [ "#000", "#069", "#455", "#455" ],
        [ "#000", "#690", "#444", "#666" ],

        # Mono

        [ "#900", "#c00", "#444", "#888" ],
        
        # Aqua 
        [ "#7b7", "#455", "#899", "#abb" ],
        [ "#005B9A", "#455", "#899", "#abb" ],
        [ "#8D009A", "#455", "#899", "#abb" ],
        [ "#9A000D", "#455", "#899", "#abb" ],
        [ "#5A9A00", "#455", "#899", "#abb" ],

        # Complementar
        #[ "#037", "#c60", "#457", "#568" ],
        #[ "#070", "#c00", "#474", "#585" ],

        # Pink
        [ "#d18", "#d18", "#457", "#668" ],
        #[ "#609", "#455", "#547", "#658" ],

        # Sand
        [ "#900", "#663", "#888", "#cc9" ],
        [ "#036", "#663", "#888", "#cc9" ],
        [ "#680", "#663", "#888", "#cc9" ]
    ]


    # Templates
    config.inital_wiki_pages = ['Ementa', 'Notas de Aula']
    config.initial_wiki_page_content = "Página em branco."
  end
end

App = WikiUFC::Application.config
