class SampleCourse < ActiveRecord::Migration
	def self.up
	
		# Cria um novo curso
  		c = Course.new
  		c.full_name = c.short_name = "Métodos Numéricos II"
  		c.description =  "Lorem ipsum dolor sit amet, consectetuer adipiscing elit." + 
  			"Etiam eu quam pharetra tellus scelerisque vehicula. Donec non sem. In hac habitasse" +
  			"platea dictumst. Integer dictum leo eget sem. Vestibulum feugiat ligula vel massa."  + 
  			"Praesent mattis. Etiam neque lorem, tincidunt eget, interdum in, malesuada et, velit." +
  			"Integer sapien mi, consequat vel, tempus sed, vehicula sit amet, quam."
  		c.save
  		
  		# Cria duas paginas wiki
  		wp_ementa = WikiPage.new(:title => "Ementa")
  		wp_notas  = WikiPage.new(:title => "Notas de Aula")
  		
  		c.wiki_pages << wp_ementa
  		c.wiki_pages << wp_notas
  		
  		# Cria uma versao para cada pagina do wiki
  		wv_ementa = WikiVersion.new(:content => "Blank page")
  		wv_notas  = WikiVersion.new(:content => "Blank page")
  		
  		wp_ementa.wiki_versions << wv_ementa
  		wp_notas.wiki_versions  << wv_notas
	end

	def self.down
	end
end
