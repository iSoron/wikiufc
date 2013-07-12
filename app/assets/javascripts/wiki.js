events['#show_preview:click'] = function(element, e)
{
	spinner_start("preview");

	new Ajax.Updater('wiki_preview', BASE_PATH + '/services/preview', {
		parameters: {
			text: $$('textarea')[0].value
		},
		onComplete: function() {
			spinner_stop("preview");
			Element.show('wiki_preview');
			new Effect.ScrollTo('wiki_preview');
		}
	});

	Event.stop(e);
};

events['#show_markup_help:click'] = function(element, e)
{
	Element.show('markup_help');
	new Effect.ScrollTo('markup_help');
	Event.stop(e);
}


function enumerate_headers()
{
	contents = "";
	elems = $('wiki_text').childElements();

	count = 0;
	headers = [];
	elems.each(function(item) {
	    if(item.match('h1') || item.match('h2') || item.match('h3') || item.match('h4') || item.match('h5')) {
	        headers[count++] = item
	    }
	});

	c1 = 0;
	c2 = 0;
	c3 = 0;
	c4 = 0;
	c5 = 0;
	ignore = 0;

	if(headers.size() - ignore <= 3) return;

	headers.each(function(item)
	{
		if(ignore-- > 0) return;

	    text = item.innerHTML;

	    if(item.match('h1')) {
			if(c5 != 0) contents += "</ol>";
			if(c4 != 0) contents += "</ol>";
			if(c3 != 0) contents += "</ol>";
			if(c2 != 0) contents += "</ol>";
			if(c1 == 0) contents += "<ol>";

	        n = (++c1);
	        c2 = c3 = c4 = c5 = 0;

			contents += "<li><a href='#" + n + "'>" + n + ". " + text + "</a></li>";
			text += "<a name='" + n + "'></a>";
	    }

	    if(item.match('h2')) {
			if(c5 != 0) contents += "</ol>";
			if(c4 != 0) contents += "</ol>";
			if(c3 != 0) contents += "</ol>";
			if(c2 == 0) contents += "<ol>";

	        n = c1 + "." + (++c2);
	        c3 = c4 = c5 = 0;

			contents += "<li><a href='#" + n + "'>" + n + ". " + text + "</a></li>";
			text += "<a name='" + n + "'></a>";
	    }

	    if(item.match('h3')) {
			if(c5 != 0) contents += "</ol>";
			if(c4 != 0) contents += "</ol>";
			if(c3 == 0) contents += "<ol>";

	        n = c1 + "." + c2 + "." + (++c3);
	        c4 = c5 = 0;

			contents += "<li><a href='#" + n + "'>" + n + ". " + text + "</a></li>";
			text += "<a name='" + n + "'></a>";
	    }

	    if(item.match('h4')) {
			if(c5 != 0) contents += "</ol>";
			if(c4 == 0) contents += "<ol>";

	        n = c1 + "." + c2 + "." + c3 + "." + (++c4);
	        c5 = 0;

			contents += "<li><a href='#" + n + "'>" + n + ". " + text + "</a></li>";
			text += "<a name='" + n + "'></a>";
	    }

	    if(item.match('h5')) {
			if(c5 == 0) contents += "<ol>";

	        n = c1 + "." + c2 + "." + c3 + "." + c4 + "." + (++c5);

			contents += "<li><a href='#" + n + "'>" + n + ". " + text + "</a></li>";
			text += "<a name='" + n + "'></a>";
	    }
	    
	    item.innerHTML = text;
	});

	$('contents').toggle();
	$('contents').innerHTML += contents;
}

