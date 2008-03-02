events['#show_preview:click'] = function(element, e)
{
	spinner_start("preview");

	new Ajax.Updater('wiki_preview', '/services/preview', {
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

function enumerate_headers()
{
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
	        text = (++c1) + ". " + text;    
	        c2 = c3 = c4 = c5 = 0;
	    }

	    if(item.match('h2')) {
	        text = c1 + "." + (++c2) + " " + text;    
	        c3 = c4 = c5 = 0;
	    }

	    if(item.match('h3')) {
	        text = c1 + "." + c2 + "." + (++c3) + " " + text;
	        c4 = c5 = 0;
	    }

	    if(item.match('h4')) {
	        text = c1 + "." + c2 + "." + c3 + "." + (++c4) + " " + text;
	        c5 = 0;
	    }

	    if(item.match('h5')) {
	        text = c2 + "." + c3 + "." + c5 + "." + (++c5) + " " + text;
	    }
	    
	    item.innerHTML = text;
	});
}

