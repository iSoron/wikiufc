xml.instruct! :xml, :version=>"1.0" 
xml.instruct! :rss, :version=>"2.0" 
xml.channel{
	for course in @courses
		for event in course.events
			xml.item do
				xml.title("[" + course.short_name + "] " + event.title)
				xml.pubDate(Time.parse(event.date.to_s).rfc822)
				xml.description(event.description)
			end
		end
	end
}
