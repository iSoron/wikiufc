xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0") do
	xml.channel do
		xml.title("#{App.title} - " + "News"[].titleize)
		xml.link(dashboard_url)
		xml.language(App.language)
		xml.description("{app} news"[:news_about, App.title])
		for news_item in @news
			xml.item do
				xml.title(news_item.course.short_name + ": " + news_item.title)
				xml.description(news_item.body)
				xml.pubDate(news_item.timestamp.rfc2822)
				xml.link(course_news_url(news_item.course, news_item))
				xml.guid(course_news_url(news_item.course, news_item))
			end
		end
	end
end
