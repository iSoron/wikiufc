events['.color_radio:click'] = function(element, e) {
    style = document.createElement('link');
	style.rel = 'Stylesheet';
	style.href = "/stylesheets/themes/color." + element.value + ".css";
	$$('head')[0].appendChild(style);
}
