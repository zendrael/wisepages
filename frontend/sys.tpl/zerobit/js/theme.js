//	JS do site

/* minha função
	testa se o JS está funcionando
*/
function teste( ) {
	//declarando variáveis
	//var a = 1;
	a = 1;
	var b = "string";
	//var c = new Array(3);
	
	//soma valores
	a = a + a;
	//concatena strings
	b = b + b;
	//b = "acesso " + "imediato" + "mais uma coisa";
	//incrementa array
	c = [1,2,3];
	c[3] = 4;
	//acessa array
	a = c[2];
	
	//pegando um elemento da tela
	elem = document.getElementById("txtNome");
	elem = elem.value;
	
	if( elem == "eu@email.com"){
		//alert("acesso garantido!");
		obj = document.getElementById("conInfo");
		obj.innerHTML = "<h2>Funcionaaaaa!!!</h2>";
		
	}else{
		alert("cai fora!");
	}
	
	//mensagem na tela
	//alert( elem );
}

// apertar Ctrl + Shift + J

function login(){
	//pega campos digitados
	login = document.getElementById("txtNome").value;
	senha = document.getElementById("txtSenha").value;
	//pega div do erro para ser usado se houver
	erro = document.getElementById("loginErro");
	//verifica se algum está em branco
	if( (login == "") || (senha == "") ){
		erro.style.display = "block";
		return( false );
	}
}//end function








/*
elem = document.getElementById("txtNome");
	elem = elem.value;
	alert( elem );

//declarando variáveis
var a = 1;
var b = "string";
var c = new Array(3);

//soma valores
a = a + a;
//concatena strings
b = b + b;
//incrementa array
c = [1,2,3];
c[3] = 4;
//acessa array
a = c[2];
*/


/*
	AJAX
	
	Asynchronous 
	Javascript
	And
	XML
*/

/* preparando o ajax */
try{
	var xmlhttp = new XMLHttpRequest();
}catch(ee){
	try{
		var xmlhttp = 
				new ActiveXObject("Msxml2.XMLHTTP");
	}catch(e){
		try{
			var xmlhttp = 
			   new ActiveXObject("Microsoft.XMLHTTP");
		}catch(E){
			var xmlhttp = false;
		}
	}
}




//função que executa o AJAX
function carregar( pagina ){
	//pega a div conteúdo
	conteudo = document.getElementById('conInfo');
	//Exibe o texto carregando no div conteúdo
	conteudo.innerHTML = "Carregando...";
	//Abre a url
	xmlhttp.open("GET", pagina, true);
	//Executada quando o navegador obtiver a resposta
	xmlhttp.onreadystatechange = function() {

		if (xmlhttp.readyState == 4){
			//Lê o texto retornado
			conteudo.innerHTML = xmlhttp.responseText;
		}
	}
	//envia requisição sem parâmetros adicionais
	xmlhttp.send(null);
}





