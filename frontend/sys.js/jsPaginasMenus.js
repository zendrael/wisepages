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
function pageMenusEdit( menuID, menuNome, menuType, menuRef, menuPos  ) {
	//get objects
	var hdnId = document.getElementById('hdnId');
	
	var lblTipoItem = document.getElementById('lblTipoItem');
	
	var edtNome = document.getElementById('edtNome');
	var selTipo = document.getElementById('selTipo');
	var selRef = document.getElementById('selRef');
	var edtPos = document.getElementById('edtPosicao');
	
	var btnSalvar = document.getElementById('btnSalvar');
	
	//change action name
	lblTipoItem.innerHTML = 'Editar item:';
	btnSalvar.value = 'alterar';
	
	//add value to hidden ID
	hdnId.value = menuID;
	
	//mark item info
	edtNome.value = menuNome;
	selTipo.selectedIndex = 1;
	selRef.selectedIndex = 1;
	edtPos.value = menuPos;
	
	//change form action
	var strAction = document.frmMenus.action;
	strAction = strAction.replace("act=1", "act=2");
	document.frmMenus.action = strAction;
	
	//focus on item name
	edtNome.focus();
	
}

