xml.instruct! :xml, :version=>"1.0" 
xml.versions do
	xml.count @wiki_page.versions.count
	xml.offset @offset
	@wiki_page.versions[(@offset.to_i)..(@offset.to_i+30)].reverse.each do |version|
		xml.version do
			xml.created_at version.created_at
			xml.updated_at version.updated_at
			xml.description version.description
			xml.title version.title
			xml.user_id version.user_id
			xml.version version.version
		end
	end
end
