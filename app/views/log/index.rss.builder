xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0") do
	xml.channel do
		xml.title("#{App.title} - #{@course.full_name} - " + I18n.t(:recent_changes).titleize)
		xml.link(course_log_url(@course))
		xml.language(App.language)
		xml.description("{course} recent changes"[:log_about, @course.full_name])
		for entry in @log_entries
			xml.item do
				description = render(:partial => 'log/log_entry.html.haml', :locals => { :entry => entry })
				xml.title("")
				xml.description(description + " por #{link_to h(entry.user.display_name), user_url(entry.user)}")
				xml.pubDate(tz(entry.created_at).rfc2822)
				xml.link(course_log_url(@course, :id => entry))
				xml.guid(course_log_url(@course, :id => entry))
			end
		end
	end
end
