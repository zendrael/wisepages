/*
	WisePages
	---------
	Content Management System
	=========================
	version 0.6b
	date 20/01/2012
	===============
	Developed by Wisetrix Technology
	--------------------------------
	www.wisetrix.com
	----------------
	main developer: Zendrael <zendrael@gmail.com>
	================================================
*/

//global vars

//generic implementation
function chkbxChange(nome) {
	if (document.getElementById(nome).value == "false") {
		document.getElementById(nome).value = "true";
	} else {
		document.getElementById(nome).value = "false";
	}
}

function chkbxAll() {
	var inputs = document.forms[0].elements;
	var cbs = [];

	for (var i = 0; i < inputs.length; i++) {
		if (inputs[i].type == "checkbox") {
				inputs[i].checked = true;
		}
	}
}

var inputs = document.forms[0].elements;
var cbs = [];

for (var i = 0; i < inputs.length; i++) {
	if (inputs[i].type == "checkbox") {
		if (inputs[i].value == "true") {
			inputs[i].checked = true;
		}
	}
}


