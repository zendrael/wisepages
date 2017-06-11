<?
	/*
	WisePages Plugin
	---------
	plugin ID: alunos
	description: controle de alunos da academia
	*/
	
	//includes
	//include_once('arquivo.php');
	
	//variáveis globais
	
	//inicia a lógica
	
	if( isset( $_REQUEST['itm'] ) ){
		echo "Plugin de <b>alunos</b> funcionando! E com parâmetros: itm=". $_REQUEST['itm'];
	}else{
		echo "Plugin de Alunos <h1>OK</h1>!";
	}
	
	//echo $_SERVER['QUERY_STRING'];
	/*for($i=0; $i<1000; $i++){
		echo "teste $i<br />";
	}*/

?>