xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0") do
	xml.channel do
		xml.title("#{App.title} - #{@course.full_name} - " + "News"[].titleize)
		xml.link(course_news_url(@course))
		xml.language(App.language)
		xml.description("{course} news"[:news_about, @course.full_name])
		for news_item in @news
			xml.item do
				xml.title(news_item.title)
				xml.description(formatted(news_item.body))
				xml.pubDate(news_item.timestamp.rfc2822)
				xml.link(course_news_instance_url(@course, news_item))
				xml.guid(course_news_instance_url(@course, news_item))
			end
		end
	end
end
