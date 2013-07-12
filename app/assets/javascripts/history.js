radios = null;

function history_from(k) {
	radios_from = k;
	history_update();
}

function history_to(k) {
	radios_to = k;
	history_update();
}

function history_update()
{
	if(radios == null) radios = document.getElementsByTagName("input");

	for(i=0; i < radios.length; i += 2) {
		if(radios[i].value >= radios_to) radios[i].style.visibility = 'hidden';
		else radios[i].style.visibility = 'visible';

		if(radios[i+1].value <= radios_from) radios[i+1].style.visibility = 'hidden';
		else radios[i+1].style.visibility = 'visible';

		if(radios[i].value == radios_from) radios[i].checked = true;
		if(radios[i+1].value == radios_to) radios[i+1].checked = true;
	}

}

