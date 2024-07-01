unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, HTTPDefs, fpHTTP, fpWeb, strutils, iniwebsession,
  //bibliotecas de banco de dados
  sqldb, sqlite3conn,
  //bibliotecas de manipulação de arquivos e imagens
  zipper, FPImage, FPCanvas, FPImgCanv, FPWritePNG, FPReadPNG, FPReadJPEG, FPWriteJPEG,
  //chamando páginas externas
  //httpsend,
  //tratando encodes
  //base64,
  //units do sistema
  untDB, untAdm, untMail, untPlugin, untBlog;

type

  { TWebModule }

  TWebModule = class(TFPWebModule)
      function checkServer( server, host: string ): boolean;
      procedure DataModuleCreate(Sender: TObject);
      procedure DataModuleRequest(Sender: TObject; ARequest: TRequest;
          AResponse: TResponse; var Handled: Boolean);

      procedure DefaultRequest(Sender: TObject; ARequest: TRequest;
          AResponse: TResponse; var Handled: Boolean);
      procedure getAdmRequest(Sender: TObject; ARequest: TRequest;
          AResponse: TResponse; var Handled: Boolean);
      {procedure DataModuleRequest(Sender: TObject; ARequest: TRequest;
          AResponse: TResponse; var Handled: Boolean);}
      procedure getCSSRequest(Sender: TObject; ARequest: TRequest;
          AResponse: TResponse; var Handled: Boolean);
      procedure getHTMLRequest(Sender: TObject; ARequest: TRequest;
          AResponse: TResponse; var Handled: Boolean);
      procedure getJSRequest(Sender: TObject; ARequest: TRequest;
          AResponse: TResponse; var Handled: Boolean);
      procedure doLoginRequest(Sender: TObject; ARequest: TRequest;
        AResponse: TResponse; var Handled: Boolean);
      procedure doLogoutRequest(Sender: TObject; ARequest: TRequest;
        AResponse: TResponse; var Handled: Boolean);
      procedure getLoginRequest(Sender: TObject; ARequest: TRequest;
          AResponse: TResponse; var Handled: Boolean);
      procedure getThumbRequest(Sender: TObject; ARequest: TRequest;
          AResponse: TResponse; var Handled: Boolean);
      procedure sendCommentRequest(Sender: TObject; ARequest: TRequest;
         AResponse: TResponse; var Handled: Boolean);
      procedure sendMailRequest(Sender: TObject; ARequest: TRequest;
          AResponse: TResponse; var Handled: Boolean);
      procedure uploadRequest(Sender: TObject; ARequest: TRequest;
          AResponse: TResponse; var Handled: Boolean);
  private
    { private declarations }
    SSession: TIniWebSession;

    //substitui as tags do lado dos temas
    procedure tagReplace(Sender: TObject; const TagString:String;
    TagParams: TStringList; Out ReplaceText: String);
    //substitui as tags para o ADMIN
    procedure tagReplaceAdmin(Sender: TObject; const TagString:String;
    TagParams: TStringList; Out ReplaceText: String);
  public
    { public declarations }
  end; 

var
  WebModule: TWebModule;
  //id da página a ser carregada
  PAGEID : string = '0';
  //id da seção de uma determinada página
  SECTIONID : string = '0';
  //path da aplicação CGI
  APPPATH : string;
  //path da url
  APPURL : string;
  //guarda requisições para o admin
  APPREQUEST : TRequest;

const
  //template dir
  TPLDIR = '../../wisepages/sys.tpl/';
  //para publicar em server Linux:
  //TPLDIR = '../sys.tpl/';

  SHAREDIR = '../../wisepages/sys.share/';
  //para publicar em server Linux:
  //SHAREDIR = '../sys.share/';

  //database
  DATABASE = 'wisepages.db';

  //controla a execução por domínio
  SERVERNAME : array[1..3] of string = ('localhost','127.0.0.1', '10.0.0.3');
  SERVER_EXTERNO = 1;

  //date arrays
  aMes: array[1..12] of string =
    ('Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
     'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro');

  aSemana: array[1..7] of string =
    ('Domingo', 'Segunda-feira', 'Terça-feira', 'Quarta-feira',
     'Quinta-feira', 'Sexta-feira', 'Sábado');

implementation

{$R *.lfm}

{ TWebModule }

{procedure TWebModule.DataModuleRequest(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean);
begin
    AResponse.ContentType := 'text/html;charset=utf-8';
    //AResponse.Contents.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'mainpage.html');
    AResponse.Content := 'i am ok!';
     Handled := True;
end;}

function TWebModule.checkServer( server, host: string ): boolean;
var
  i: integer;
  b: boolean;
begin
	 for i:= 1 to 3 do begin
         if AnsiContainsStr( server, SERVERNAME[i] ) and AnsiContainsStr( host, SERVERNAME[i] ) then
         begin
             (*if HttpGetText('http://www.wisepages.com/auth/dominio.auth', strResponse) then
    		 begin
		 	 	  //retorna
    	 	 	  Result:= strResponse.Text;*)
     	 	  b:= True;
              Break;
         end else
		 	  b:= False;
     end;
     Result := b;
end;

procedure TWebModule.DataModuleCreate(Sender: TObject);
begin
    {Session := TIniWebSession.Create(Self);
    (SessionFactory as TIniSessionFactory).SessionDir := '/mysessions';}
    (SessionFactory as TIniSessionFactory).SessionDir := './tmp';
end;

procedure TWebModule.DataModuleRequest(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean);
begin
    {Session.InitSession(ARequest, nil, nil);
    Session.InitResponse(AResponse);}
end;

procedure TWebModule.DefaultRequest(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean);
begin
     Handled:= true;
     //return some page dynamically
     AResponse.ContentType := 'text/html;charset=utf-8';
     AResponse.Contents.Add('<h1>wisepages Technology</h1>');
     AResponse.Contents.Add('<h3><a href="http://www.wisepages.com">www.wisepages.com</a></h3><hr/>');

     if not checkServer( ARequest.Server, ARequest.Host ) then
     begin
          AResponse.Contents.Add('<b><span style="color:red;">SOFTWARE NÃO LICENCIADO!</span></b>');
     end;
end;

//procedure para substituição de tags
procedure TWebModule.tagReplace(Sender: TObject; const TagString:
  String; TagParams: TStringList; Out ReplaceText: String);
var
  dia, mes, ano: word;
  straux : string;
  strlst : TStrings;
begin
  if AnsiCompareText(TagString, 'wiseDateNow') = 0 then begin
       decodedate( now, ano, mes, dia );
       ReplaceText := Format('%s, %d de %s de %d',[aSemana[DayOfWeek(now)], dia, aMes[mes], ano]);
       //ReplaceText := FormatDateTime('dddd, dd "de" mmmm "de" yyyy', Now  );
  end;(* else begin
      //Not found value for tag -> TagString
      ReplaceText := 'ModuleTemplate tag {' + TagString + '} is not implemented yet.';
  end;*)

  if AnsiCompareText(TagString, 'wiseConfigItem') = 0 then begin

        ReplaceText:= TuntDB.getConfigItem( TagParams.Values['get'], DATABASE);
  end;

  if AnsiCompareText(TagString, 'wiseInfo') = 0 then begin
        //recupera informações direto do banco de dados e retorna as tags
        ReplaceText := TuntDB.getInfo( TPLDIR, DATABASE );
  end;

  if AnsiCompareText(TagString, 'wiseMailPath') = 0 then begin
        //pega o caminho do executável
        ReplaceText := 'email?r='+APPURL;
  end;

  if AnsiCompareText(TagString, 'wiseCommentPath') = 0 then begin
        //pega o caminho do executável
        ReplaceText := 'comment?r='+APPURL;
  end;

  //header
  if AnsiCompareText(TagString, 'wiseHeader') = 0 then begin
        ModuleTemplate.FileName := TPLDIR + TuntDB.getConfigItem('template', DATABASE ) + '/header.html';

        ReplaceText := ModuleTemplate.GetContent;
  end;

  //menus
  if AnsiCompareText(TagString, 'wiseMenu') = 0 then begin
        //pega os menos pela base de dados e retorna no formato <ul><li><a ...>menuitem</a></li>...</ul>
        ReplaceText:= TuntDB.getMenu( TagParams, DATABASE );
  end;

  //
  if AnsiCompareText(TagString, 'wiseBody') = 0 then begin
        ModuleTemplate.FileName := TPLDIR + TuntDB.getConfigItem('template', DATABASE ) + '/body.html';

        ReplaceText := ModuleTemplate.GetContent;
  end;

  //
  if AnsiCompareText(TagString, 'wisePageLoad') = 0 then begin
        //SE houver página a ser carregada...
        // <> 0 processa página
        if AnsiCompareStr(PAGEID,'0') <> 0 then begin
            //consulta ID na base
            straux := TuntDB.getPage( DATABASE, PAGEID );
            //checa se retornou resultado
            if AnsiContainsStr( straux, '|' ) then begin
                //prepara array de strings
                strlst := TStringList.Create;
                strlst.StrictDelimiter:= true;
                //separa a string
                ExtractStrings( ['|'], [], PChar(straux), strlst );
                //verifica se conteúdo é inerno ou externo
                //se interno
                if( AnsiCompareText( strlst[1], 'page') = 0 ) then
                begin
                     ReplaceText:= strlst.Text;
                end
                //se externo
                else begin
                    ModuleTemplate.FileName := TPLDIR + TuntDB.getConfigItem('template', DATABASE ) + '/'+ strlst[2];
                    {ModuleTemplate.AllowTagParams := true;
                    ModuleTemplate.OnReplaceTag := @tagReplace;}

                    ReplaceText := ModuleTemplate.GetContent;
                end;
            end
            else begin
                 ReplaceText:= straux;
            end;
        end
        //verifica se há uma página inicial a ser carregada...
        else begin
        	 //consulta ID na base
            straux := TuntDB.getPageMain( DATABASE );
            //checa se retornou resultado
            if AnsiContainsStr( straux, '|' ) then begin
                //prepara array de strings
                strlst := TStringList.Create;
                strlst.StrictDelimiter:= true;
                //separa a string
                ExtractStrings( ['|'], [], PChar(straux), strlst );
                //verifica se conteúdo é inerno ou externo
                //se interno
                if( AnsiCompareText( strlst[1], 'page') = 0 ) then
                begin
                     ReplaceText:= strlst[2];
                end
                //se externo
                else
                begin
                    ModuleTemplate.FileName := TPLDIR + TuntDB.getConfigItem('template', DATABASE ) + '/'+ strlst[2];

                    ReplaceText := ModuleTemplate.GetContent;
                end;
            end
            else begin
                 ReplaceText:= straux;
            end;
        end;
  end;

  //
  if AnsiCompareText(TagString, 'wisePlugin') = 0 then begin
  	    //chama plugin
        ReplaceText := TuntPlugin.getPlugin( TagParams.Values['name'], TagParams.Values['params'], APPREQUEST, DATABASE );
  end;

  //blog completo
  if AnsiCompareText(TagString, 'wiseBlog') = 0 then begin

        ReplaceText := TuntBlog.getBlog( TagParams, APPREQUEST, DATABASE, APPURL );
  end;

  //tags de itens (posts) do blog
  {if AnsiCompareText(TagString, 'wiseBlogTags') = 0 then begin
        //carrega informações do banco na forma <ul><li><a ...>nome_da_tag</a></li>...</ul>
        ReplaceText := TuntBlog.getBlogTags( TagParams, DATABASE );
  end;}

  //footer
  if AnsiCompareText(TagString, 'wiseFooter') = 0 then begin
        ModuleTemplate.FileName := TPLDIR + TuntDB.getConfigItem('template', DATABASE ) + '/footer.html';

        ReplaceText := ModuleTemplate.GetContent;
  end;

end;

procedure TWebModule.tagReplaceAdmin(Sender: TObject; const TagString:
  String; TagParams: TStringList; Out ReplaceText: String);
var
  //dia, mes, ano: word;
  straux : string;
  //strlst : TStrings;
begin

  if AnsiCompareText(TagString, 'wisePageLoad') = 0 then begin
        //SE houver página a ser carregada...
        // <> 0 processa página
        if AnsiCompareStr(PAGEID,'0') <> 0 then begin

           //base dos forms
           straux := StringReplace(TPLDIR, 'tpl', 'adm', [rfReplaceAll]);

           //ReplaceText:= TuntAdm.getPage(APPURL, PAGEID, SECTIONID, StringReplace(TPLDIR, 'tpl', 'adm', [rfReplaceAll]) + 'frmTemas.html', APPREQUEST, DATABASE, Self);
           ReplaceText:= TuntAdm.getPage(APPURL, PAGEID, SECTIONID, straux, APPREQUEST, DATABASE, Self);

        end else
        begin
           	straux := StringReplace(TPLDIR, 'tpl', 'adm', [rfReplaceAll]);

           	ReplaceText := TuntAdm.getPage(APPURL, PAGEID, SECTIONID, straux, APPREQUEST, DATABASE, Self);
        end;
  end;

  //carrega os itens (forms, listas, mensagens...) nas páginas
  {if AnsiCompareText(TagString, 'wisePageItem') = 0 then begin
  	    //chama os itens de cada página
        ReplaceText:= TuntAdm.getPage(APPURL, PAGEID, SECTIONID, StringReplace(TPLDIR, 'tpl', 'adm', [rfReplaceAll]) + 'frmTemas.html', APPREQUEST, DATABASE, Self);
  end;

  if AnsiCompareText(TagString, 'wiseAdmPath') = 0 then begin
        //pega o caminho do executável
        ReplaceText := APPURL;
  end;}

end;

procedure TWebModule.getCSSRequest(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean);
begin
     Handled:= true;
     //return CSS code
     AResponse.ContentType := 'text/css;charset=utf-8';
end;

procedure TWebModule.getJSRequest(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean);
begin
     Handled:= true;
     //return JS code
     AResponse.ContentType := 'text/javascript;charset=utf-8';
end;

procedure TWebModule.doLoginRequest(Sender: TObject; ARequest: TRequest;
  AResponse: TResponse; var Handled: Boolean);
var
   vals : array [1..3] of string;
begin

     AResponse.ContentEncoding := 'UTF-8';
     //AResponse.ContentType := '';

     //pega valores
     if( LowerCase( ARequest.Method ) = 'get') then //via GET
     begin
       vals[1] := ARequest.QueryFields.Values['edtLogin'];
       vals[2] := ARequest.QueryFields.Values['edtSenha'];
     end
     else
     begin //via POST
       vals[1] := ARequest.ContentFields.Values['edtLogin'];
       vals[2] := ARequest.ContentFields.Values['edtSenha'];
     end;

     vals := TuntDB.doLogin( vals[1], vals[2], DATABASE );

     if vals[1] <> 'ERROR' then
     begin
     	  //registra sessão
          if CreateSession and Assigned(Session) then
          begin
              //setando variáveis de sessão
              Session.Variables['UID'] :=  vals[1];
              Session.Variables['UNAME'] := vals[2];
              Session.Variables['UTYPE'] := vals[3];

              //responde OK
              AResponse.Location := 'admin'; //'http://' + ARequest.Server + '/wisepages/admin';
     	  end
     	  else
		  begin
          	   AResponse.Content:= 'Erro criando sessão!';
          end;
     end
     else
     begin
     	  AResponse.Content:= vals[2];
     end;

    //send content
    Handled:=True;
end;

procedure TWebModule.doLogoutRequest(Sender: TObject; ARequest: TRequest;
  AResponse: TResponse; var Handled: Boolean);
begin
  //destrói sessão
  Session.Terminate;
  //responde
  //AResponse.Content := '{ERROR:"",msg:"",action:"doLogout()"}';
  AResponse.Location := 'login';

  Handled:= True;
end;

procedure TWebModule.getLoginRequest(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean);
begin
	 AResponse.ContentType := 'text/html;charset=utf-8';

     //antes de executar algo, valida o server
     if checkServer(ARequest.Server, ARequest.Host) then
     begin
	     if Session.Variables['UID'] = EmptyStr then
         begin
            //ninguém está logado, mostra form de login
		    AResponse.Contents.LoadFromFile( StringReplace(TPLDIR, 'tpl', 'adm', [rfReplaceAll]) + '/frmLogin.html' );
         end
         else begin
	        //pronto para carregar o template do admin
            AResponse.Location := 'admin';
         end;

     end else
     begin
         //servidor nao licenciado...
         DefaultRequest(sender, ARequest, AResponse, Handled);
     end;

     Handled := true;
end;

procedure TWebModule.getThumbRequest(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean);
var
  fs : TFileStream;
  image,img2 : TFPCustomImage;
  reader : TFPCustomImageReader;
  writer : TFPCustomImageWriter;
  imgcnv, imgcnv2 : TFPImageCanvas;
  memstr : TMemoryStream;
  rect : TRect;
  //preparando as variáveis
  h,w : integer;
  fator : real;
begin
    try
        //inicializa variáveis
      	h:= 0; //altura
        w:= 0; //largura
        fator:= 0.0; //fator de proporção para ajuste

       	//pega as variáveis SE passadas por parâmetro
        if( ( ARequest.QueryFields.Values['width'] <> '' ) and ( ARequest.QueryFields.Values['height'] <> '' ) ) then
        begin
            w:= StrToInt( ARequest.QueryFields.Values['width'] );
        	h:= StrToInt( ARequest.QueryFields.Values['height'] );
        end else if ( ARequest.QueryFields.Values['width'] <> '' ) then
        begin
            w:= StrToInt( ARequest.QueryFields.Values['width'] );
        end else if ( ARequest.QueryFields.Values['height'] <> '' ) then
        begin
            h:= StrToInt( ARequest.QueryFields.Values['height'] );
        end;

       	//define o tipo de retorno
        //define tipo do reader e writer
        {if ( LowerCase( ExtractFileExt( ARequest.QueryFields.Names[0] ) ) = 'jpg' ) or
           ( LowerCase( ExtractFileExt( ARequest.QueryFields.Names[0] ) ) = 'jpeg' ) then
        begin}
        	 AResponse.ContentType:= 'image/jpeg';
             //cria itens para ler e escrever imagens do tipo
  	    	 reader := TFPReaderJPEG.Create;
        	 writer := TFPWriterJPEG.Create;
        {end else
        begin
             AResponse.ContentType:= 'image/png';
             //cria itens para ler e escrever imagens do tipo
  	    	 reader := TFPReaderPNG.Create;
        	 writer := TFPWriterPNG.Create;
        end;}

        //abre arquivo para leitura
        fs:= TFileStream.Create(UTF8ToSys( SHAREDIR + ARequest.QueryFields.Names[0] ), fmOpenRead);

        //cria imagem na memória para manipulação
        image := TFPMemoryImage.Create(800, 600);

        //image.UsePalette:= false;

        //carrega do stream
        image.LoadFromStream(fs, reader);

        //prepara o canvas a partir da imagem 1
        imgcnv:= TFPImageCanvas.create( image );

        //calcula fator (de redimensionamento) de acordo com a imagem
        if (h <> 0 ) or (w <> 0) then
        begin
            if ( h > w ) then
            begin
                fator := image.Height / h ;
                w := round( image.Width / fator );
            end else
            begin
                fator := image.Width / w ;
                h := round( image.Height / fator );
            end;
        end else begin
           h:= 100;
           w:= 100;
        end;

        //redimensiona canvas
        imgcnv.StretchDraw( 0,0, w,h, image);

        //prepara área a ser recortada
        rect.Top:= 0;
        rect.Left:= 0;
        rect.Bottom:= h;
        rect.Right:= w;

        //criando imagem 2
        img2 := TFPMemoryImage.Create( w, h );
        //prepara canvas da segunda imagem
        imgcnv2:= TFPImageCanvas.create( img2 );
        //copia a parte reduzida da imagem 1 (canvas1) para o canvas2
        imgcnv2.CopyRect(0,0, imgcnv, rect);
        //associa a imagem
        img2:=  imgcnv2.Image;

        //img2.UsePalette:= false;

        //prepara o stream para retornar
        memstr:= TMemoryStream.Create;

        //grava imagem gerada no stream
        img2.SaveToStream( memstr, writer );

	    //responde com imagem salva no stream
	    AResponse.ContentStream:= memstr;

        //envia conteúdo
        AResponse.SendContent;

        Handled:= true;
    finally
	    //limpando a memória
        fs.Free;
  		image.Free;
        img2.Free;
  		reader.Free;
  		writer.Free;
  		imgcnv.Free;
        imgcnv2.Free;
  		memstr.Free;
    end;
end;


procedure TWebModule.sendMailRequest(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean);
var
  straux : string;
begin
	 AResponse.ContentType := 'text/html;charset=utf-8';

     if checkServer(ARequest.Server, ARequest.Host) then
     begin
         //monta e-mail (pegando valores por post)
         straux:= sLineBreak + 'Nome: ' + ARequest.ContentFields.Values['edtNome'] + ' <' + ARequest.ContentFields.Values['edtEmail'] + '>' + sLineBreak;
         straux:= straux + 'Fone: ' + ARequest.ContentFields.Values['edtFone'] + sLineBreak;
         straux:= straux + 'Mensagem: ' + sLineBreak +  ARequest.ContentFields.Values['txtMensagem'];

	     //envia e-mail
         //---------------(quem, assunto, mensagem);
         if TuntMail.sendMail( ARequest.ContentFields.Values['edtEmail'], ARequest.ContentFields.Values['edtAssunto'], straux, DATABASE) then
         begin
             //Handled := true;
         	 AResponse.Location := 'http://' + ARequest.Server + ARequest.QueryFields.Values['r'] +'#msgOk';
         end else
         begin
		     //Handled := true;
         	 AResponse.Location := 'http://' + ARequest.Server + ARequest.QueryFields.Values['r'] +'#msgEr';
         end;

     end else
     begin
         //servidor nao licenciado...
         DefaultRequest(sender, ARequest, AResponse, Handled);
     end;

     Handled := true;
end;

procedure TWebModule.sendCommentRequest(Sender: TObject; ARequest: TRequest;
   AResponse: TResponse; var Handled: Boolean);
var
  straux: string;
  //i: integer;
begin
   AResponse.ContentType := 'text/html;charset=utf-8';

   //converte URL
   //há vários parâmetros de retorno que são recolocados
   if ARequest.QueryFields.Values['r'] <> EmptyStr then
   	straux:= StringReplace( ARequest.QueryFields.Values['r'], '_', '&', [rfReplaceAll] )
   else
   	straux:= '?pst='+ ARequest.ContentFields.Values['postID'];

   if checkServer(ARequest.Server, ARequest.Host) then
   begin
      if TuntBlog.setBlogComment( ARequest, DATABASE ) then
      begin
         //ok, commentário enviado
         AResponse.Location := 'http://' + ARequest.Server + straux +'#msgOk';
      end else
      begin
         //erro
         AResponse.Location := 'http://' + ARequest.Server + straux +'#msgEr';
      end;
   end else
   begin
      //servidor nao licenciado...
      DefaultRequest(sender, ARequest, AResponse, Handled);
	end;

   Handled := true;

end;

procedure TWebModule.uploadRequest(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean);
var
   UnZipper: TUnZipper;
begin
    AResponse.ContentType := 'text/html;charset=utf-8';

    try
      if ARequest.Files.Count > 0 then
      begin
         if ARequest.Files[0].ContentType <> 'application/zip' then
         begin
         	  CopyFile( ARequest.Files[0].LocalFileName, SHAREDIR + ARequest.Files[0].FileName );
         end
         else begin
             // se for arquivo zip
             UnZipper := TUnZipper.Create;
             try
                UnZipper.FileName := ARequest.Files[0].LocalFileName;
                UnZipper.OutputPath := SHAREDIR;
                UnZipper.Examine;
                UnZipper.UnZipAllFiles;
             finally
                UnZipper.Free;
             end;
      	 end;
         //responde à página
         //AResponse.Content := ARequest.Files[0].FileName + ' - ' + ARequest.Files[0].ContentType;
         AResponse.Location := 'http://' + ARequest.Server + ARequest.QueryFields.Values['r'] +'#msgOk';
      end;
    finally
      ARequest.Files.Free;
    end;
    Handled:= true;
end;

procedure TWebModule.getAdmRequest(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean);
begin
	 AResponse.ContentType := 'text/html;charset=utf-8';

     if checkServer(ARequest.Server, ARequest.Host) then
     begin

	     if Session.Variables['UID'] = EmptyStr then
         begin
            //ninguém está logado, mostra form de login
		    AResponse.Location := 'login';
         end
         else begin

            if( ARequest.QueryFields.Values['p'] <> '' )then
     	    begin
            	 PAGEID := ARequest.QueryFields.Values['p'];
                 APPPATH:= ARequest.ScriptName;  // retorna /cgi-bin/pasta/arquivo.cgi
             	 APPURL:= ARequest.URL; //retorna url
                 APPREQUEST:= ARequest;
            end;

            if( ARequest.QueryFields.Values['i'] <> '' )then
     	    begin
            	 SECTIONID := ARequest.QueryFields.Values['i'];
            end;

	        //pronto para carregar o template do admin
	        ModuleTemplate.FileName := StringReplace(TPLDIR, 'tpl', 'adm', [rfReplaceAll]) + '/main.html';
            ModuleTemplate.AllowTagParams := true;
            //set tag params to be used like
            // {wiseTag param1="" param2=""}
            ModuleTemplate.ParamStartDelimiter := ' ';
  			ModuleTemplate.ParamEndDelimiter := '"';
  			ModuleTemplate.ParamValueSeparator := '="';
            //
            ModuleTemplate.OnReplaceTag := @tagReplaceAdmin;

            AResponse.Content := ModuleTemplate.GetContent;

         end;

     end else
     begin
         //servidor nao licenciado...
         DefaultRequest(sender, ARequest, AResponse, Handled);
     end;

     Handled := true;
end;

procedure TWebModule.getHTMLRequest(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean);
begin
     //return some page dynamically
     AResponse.ContentType := 'text/html;charset=utf-8';

     //servidor autorizado para executar este CGI
     if checkServer(ARequest.Server, ARequest.Host) then
     begin

         if( ARequest.QueryFields.Values['p'] <> '' )then
         begin
             PAGEID := ARequest.QueryFields.Values['p'];
             APPPATH:= ARequest.ScriptName;  // retorna /cgi-bin/pasta/arquivo.cgi
             APPURL:= ARequest.URL;
         end;// else
         //begin
             //mantem o request para uso dos plugins
             APPREQUEST:= ARequest;

             //toda acao sem identificação, cai no home
             ModuleTemplate.FileName :=  TPLDIR + TuntDB.getConfigItem('template', DATABASE ) + '/main.html';
             ModuleTemplate.AllowTagParams := true;
             //set tag params to be used like
             // {wiseTag param1="" param2=""}
             ModuleTemplate.ParamStartDelimiter := ' ';
  	     ModuleTemplate.ParamEndDelimiter := '"';
  	     ModuleTemplate.ParamValueSeparator := '="';
             //
             ModuleTemplate.OnReplaceTag := @tagReplace;

             AResponse.Content := ModuleTemplate.GetContent;
         //end;
     end else
     begin
         //servidor nao licenciado...
         DefaultRequest(sender, ARequest, AResponse, Handled);
     end;

     Handled := true;
end;


initialization
  (*ShortDateFormat := 'dd/MM/yyyy';
  CurrencyString := 'R$';
  CurrencyFormat := 0;
  NegCurrFormat := 14;
  ThousandSeparator := '.';
  DecimalSeparator := ',';
  CurrencyDecimals := 2;
  DateSeparator := '/';
  TimeSeparator := ':';
  TimeAMString := 'AM';
  TimePMString := 'PM';
  ShortTimeFormat := 'hh:mm:ss';*)
  RegisterHTTPModule('WebModule', TWebModule);
end.

