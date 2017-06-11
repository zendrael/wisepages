<?
	/*
	WisePages Plugin
	---------
	plugin ID: banner
	description: banner aleatório lateral
	*/
	
	//includes
	//include_once('arquivo.php');
	
	//variáveis globais
	
	//inicia a lógica
	echo "<p><div style='width:240; text-align:center;'>";
	
	$num = rand(1, 3);
	$num = ( $num < 9 ) ? '0'.$num : $num; 
	$num = 'sys.share/banner_'.$num.'.png';
	
	echo "<img src='".$num."' width='240' height='400' alt='".$num."'/>";
	
	echo "</div></p>";

?>