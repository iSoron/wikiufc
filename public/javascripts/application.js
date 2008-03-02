events = {};

events['#password:keyup'] = function(element, e) {
	passmeter();
};

function startup() {
	EventSelectors.start(events);	

	var validation_box = $('validation');
	if(validation_box != null) new Effect.Appear(validation_box);

	$$('.highlight').each(function(e) {
		new Effect.Highlight(e, {duration: 1.5});
	});

	if(window.history_update) history_update();
}

spin_count = Array();
function spinner_start(s)
{
	if(spin_count[s]) spin_count[s]++;
	else spin_count[s] = 1;

	$("spinner_" + s).show();
}

function spinner_stop(s)
{
	spin_count[s]--;
	if(spin_count[s] == 0) $("spinner_" + s).hide();
}

function passmeter()
{
	var pass = $F('password');
	var meter = $('passmeter');
	var nivel = 0;
	
	if(pass.length == 0) {
		meter.innerHTML = "&nbsp;";
		return;
	}
	
	if(pass.length >= 6) {
		if(/[a-z_]/.test(pass)) nivel++;
		if(/[A-Z]/.test(pass)) nivel++;
		if(/[0-9]/.test(pass)) nivel++;
		if(/\W/.test(pass)) nivel++;
		
		if(pass.length >= 10) nivel++;
	}
	
	switch(nivel) {
		case 0: case 1:
			msg = "senha muito fraca";
			cor = "#d00";
			break;
			
		case 2:
			msg = "senha fraca";
			cor = "#f50";
			break;
			
		case 3:
			msg = "senha moderada";
			cor = "#090";
			break;
			
		case 4: default:
			msg = "senha forte";
			cor = "#05f";
			break;			
	}
	
	meter.style.color = cor;
	meter.innerHTML = msg;
}

Ajax.Responders.register({
	onComplete: function() { EventSelectors.assign(events);}
})
