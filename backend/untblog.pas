unit untBlog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  //unit is using
  HTTPDefs, RegExpr, math, sqldb, db,
  //also system units
  untDB;

type
  { untBlog }

  { TuntBlog }

  TuntBlog = class
  private
    { private declarations }
    class var APPURL: string;
  public
    { public declarations }
    class procedure setAPPURL( url: string);
    class function getAPPURL(): string;

    class function getBlog( TagParams: TStringList; ARequest: TRequest; db:string; URL: string ): string;
    class function getBlogCommentCount( postid: string ): string;
    class function getBlogPostTags( postid: string ): string;
    class function getBlogComments( postid: string ): string;
    class function setBlogComment( Arequest: TRequest; db: string): boolean;
    class function getBlogCommentLast(): string;
    class function setBlogCommentForm( postid: string ): string;
    class function getBlogConfigItem( strItem: string) : string;

    constructor Create;
    destructor Destroy; override;
  end;


implementation

class procedure TuntBlog.setAPPURL(url: string);
begin
   self.APPURL:= url;
end;

class function TuntBlog.getAPPURL: string;
begin
	Result:= self.APPURL;
end;

class function TuntBlog.getBlog( TagParams: Tstringlist; ARequest: TRequest; db: string; URL: string ): string;
var
    straux, straux2, strURL : string;
    intinicio, intlimite, inttotal: integer;

	//função interna para tratar a URL da paginação
    function geraURLpaginada( strPgNum: string ): string;
    var
        strPg: String;
    begin
        if( Pos('?', ARequest.URL) <> 0 ) then
            //verifica se já existe algum 'lmt'
            if ExecRegExpr( 'lmt=', ARequest.URL ) then
            begin
               //achou campo na URL, só substitui
               strPg:= 'lmt=' +  strPgNum;
               Result:= ReplaceRegExpr('lmt=[0-9]+', ARequest.URL, strPg, false)
            end
            else
               Result:= ARequest.URL + '&lmt=' + strPgNum //ReplaceRegExpr('lmt=([0-9]+)', strURL, 'lmt=', False)
        else
            Result:= ARequest.URL + '?lmt=' + strPgNum;
    end;
begin

    setAPPURL( URL );

    if TuntDB.Connect( db ) then
    begin
        try
            with SQLQuery do
            begin
                 //zera a query
                 Close;

                 //se for solicitado um post específico, mostra ele
                 if ARequest.QueryFields.Values['pst'] <> '' then
                 begin

                     SQL.Add('SELECT id, title, strftime("%Y-%m-%d %H:%M:%S", datahora) AS `datahora`, message ');
                     SQL.Add('FROM tbblogpost ');
                     SQL.Add('WHERE id='+ ARequest.QueryFields.Values['pst'] +';');
                     Open;

                     if RecordCount > 0  then
                     begin
                        straux := '';

                        straux:= straux + '<div class='''+ TagParams.Values['postbody'] +''' >';
                        straux:= straux + '<h1>'+ FieldByName('title').AsString +'</h1>';
                        straux:= straux + '<p>'+ FieldByName('message').AsString +'</p>';

                        //data, autor, e tags
                        straux:= straux + '<div class='''+ TagParams.Values['postinfo'] +''' >' + FieldByName('datahora').AsString + ' ';
                        //autor desabilitado
                        //straux:= straux + getBlogPostAuthor( FieldByName('datahora').AsString );
                        //tags
                        straux:= straux + getBlogPostTags( FieldByName('id').AsString );
                        //fim div
                        straux:= straux + '</div>';

                        //fim do post
                        straux:= straux + '</div>';

                        //prepara comentários e marca com uma âncora
                        straux:= straux + '<div><a name="comment">Comentários:</a></div>';

                        //comentários completos do post
                        straux:= straux + '<div class="'+ TagParams.Values['postcomments'] +'">' + getBlogComments( FieldByName('id').AsString ) + '</div>';

                        //form para envio de novo comentárip
                        straux:= straux + setBlogCommentForm( FieldByName('id').AsString );


                        Result:= straux;
                     end
                     else begin
                         //não há posts definidos
                         Result:= '<b>Post não encontrado!</b>';
                     end;

                 end
                 else

                 //se for solicitado mostrar os posts por tag...
                 if ARequest.QueryFields.Values['tag'] <> '' then
                 begin
				 	 straux:= '<h2>Exibindo posts por assunto:</h2>';

                     //verifica se algum limite foi passado
                     if( ARequest.QueryFields.Values['lmt'] <> '') then
                         intlimite:= StrToInt( ARequest.QueryFields.Values['lmt'] )
                     else
                         intlimite:= 0;

                     //multiplica o limite passado pela quantidade por página guardada no banco
                     intinicio:= intlimite * StrToInt( getBlogConfigItem('postlimit') );

                     //pega o total para trabalhar
                     SQL.Add('SELECT COUNT(tbbp.id) AS `total` ');
                     SQL.Add('FROM tbblogpost AS `tbbp`, tbblogtags AS `tbbt`, tbblogposttags AS `tbbpt` ');
                     SQL.Add('WHERE  tbbpt.idpost = tbbp.id AND tbbpt.idcategory = tbbt.id AND tbbpt.idcategory = '+ARequest.QueryFields.Values['tag']+' ');
                     Open;
                     //calcula total de páginas
                     inttotal:= ceil( FieldByName('total').AsInteger / StrToInt( getBlogConfigItem('postlimit') ) );

                     //realiza consulta aos posts de acordo com a tag esperada
                     Close;
                     SQL.Clear;
                     SQL.Add('SELECT tbbp.id, tbbp.title, tbbp.datahora, tbbp.message, tbbt.name ');
                     SQL.Add('FROM tbblogpost AS `tbbp`, tbblogtags AS `tbbt`, tbblogposttags AS `tbbpt` ');
                     SQL.Add('WHERE  tbbpt.idpost = tbbp.id AND tbbpt.idcategory = tbbt.id AND tbbpt.idcategory = '+ARequest.QueryFields.Values['tag']+' ');
                     SQL.Add('ORDER BY tbbp.datahora DESC ');
                     SQL.Add('LIMIT '+ IntToStr( intinicio) +','+ getBlogConfigItem('postlimit') +'; ');
                     Open;

                     if RecordCount > 0  then
                     begin

                        while not EOF do begin
                          straux:= straux + '<div class='''+ TagParams.Values['postbody'] +''' >';
                          straux:= straux + '<h1>'+ FieldByName('title').AsString +'</h1>';
                          straux:= straux + '<p>'+ FieldByName('message').AsString +'</p>';

                          //data, autor, e tags
                          straux:= straux + '<div class='''+ TagParams.Values['postinfo'] +''' >' + FieldByName('datahora').AsString + ' ';
                          //autor desabilitado
                          //straux:= straux + getBlogPostAuthor( FieldByName('datahora').AsString );
                          //tags
                          straux:= straux + getBlogPostTags( FieldByName('id').AsString );
                          //fim div
                          straux:= straux + '</div>';

                          //pega quantidade de comentários e cria link
                          if( Pos('?', ARequest.URL) <> 0 ) then
                          	  strURL :=  ARequest.URL + '&'
                          else
                              strURL:= '?';

                          straux:= straux + '<a href="'+ strURL +'pst='+ FieldByName('id').AsString +'#comment">' + getBlogCommentCount( FieldByName('id').AsString ) +'</a>';

                          //fim do post
                          straux:= straux + '</div>';

                          next;
                        end;

                        //cria paginação
                        straux2:= '<div class="'+ TagParams.Values['postpages'] +'">';

                        //anterior
                        if( intlimite > 0 ) then
                        	straux2:= straux2 + '<a href="'+ geraURLpaginada( IntToStr( intlimite -1 ) ) +'">'+ getBlogConfigItem('prevpoststr') +'</a> | '
                        else
                            //cria link desabilitado
                            straux2:= straux2 + '<a disabled="true">'+ getBlogConfigItem('prevpoststr') +'</a> | ';

                        //próximo
                        if( intlimite < (inttotal-1) ) then
                        	straux2:= straux2 + '<a href="'+ geraURLpaginada( IntToStr( intlimite + 1 ) ) +'">'+ getBlogConfigItem('nextpoststr') +'</a>'
                        else
                            //cria link desabilitado
                            straux2:= straux2 + '<a disabled="true">'+ getBlogConfigItem('nextpoststr') +'</a>';

                        straux2:= straux2 + '</div>';

                        Result:= straux + straux2;
                     end
                     else begin
                         //não há posts definidos
                         Result:= '<b>Sem posts nesta categoria!</b>';
                     end;

                 end
                 else

                 begin
                 //se não, mostra todos
                 //de acordo com a paginação

                     //verifica se algum limite foi passado
                     if( ARequest.QueryFields.Values['lmt'] <> '') then
                     	 intlimite:= StrToInt( ARequest.QueryFields.Values['lmt'] )
                     else
                         intlimite:= 0;

                     //multiplica o limite passado pela quantidade por página guardada no banco
                     intinicio:= intlimite * StrToInt( getBlogConfigItem('postlimit') );

                     //pega o total para trabalhar
                     Sql.Text:= 'SELECT COUNT(id) AS `total` FROM tbblogpost;';
                     Open;
                     //calcula total de páginas
                     inttotal:= ceil( FieldByName('total').AsInteger / StrToInt( getBlogConfigItem('postlimit') ) );

                     //monta query com o limite
                     Close;
                     SQL.Clear;
                     SQL.Add('SELECT id, title, strftime("%Y-%m-%d %H:%M:%S", datahora) AS `datahora`, message ');
                     SQL.Add('FROM tbblogpost ');
                     SQL.Add('ORDER BY datahora DESC ');
                     SQL.Add('LIMIT '+ IntToStr( intinicio) +','+ getBlogConfigItem('postlimit') +'; ');
                     Open;

                     if RecordCount > 0  then
                     begin
                        straux := '';

                        while not EOF do begin
                          straux:= straux + '<div class='''+ TagParams.Values['postbody'] +''' >';
                          straux:= straux + '<h1>'+ FieldByName('title').AsString +'</h1>';
                          straux:= straux + '<p>'+ FieldByName('message').AsString +'</p>';

                          //data, autor, e tags
                          straux:= straux + '<div class='''+ TagParams.Values['postinfo'] +''' >' + FieldByName('datahora').AsString + ' ';
                          //autor desabilitado
                          //straux:= straux + getBlogPostAuthor( FieldByName('datahora').AsString );
                          //tags
                          straux:= straux + getBlogPostTags( FieldByName('id').AsString );
                          //fim div
                          straux:= straux + '</div>';

                          //pega quantidade de comentários e cria link
                          if( Pos('?', ARequest.URL) <> 0 ) then
                          	  strURL :=  ARequest.URL + '&'
                          else
                              strURL:= '?';

                          straux:= straux + '<a href="'+ strURL +'pst='+ FieldByName('id').AsString +'#comment">' + getBlogCommentCount( FieldByName('id').AsString ) +'</a>';

                          //fim do post
                          straux:= straux + '</div>';

                          next;
                        end;

                        //cria paginação
                        straux2:= '<div class="'+ TagParams.Values['postpages'] +'">';

                        //anterior
                        if( intlimite > 0 ) then
                        	straux2:= straux2 + '<a href="'+ geraURLpaginada( IntToStr( intlimite -1 ) ) +'">'+ getBlogConfigItem('prevpoststr') +'</a> | '
                        else
                            //cria link desabilitado
                            straux2:= straux2 + '<a disabled="true">'+ getBlogConfigItem('prevpoststr') +'</a> | ';

                        //próximo
                        if( intlimite < (inttotal-1) ) then
                        	straux2:= straux2 + '<a href="'+ geraURLpaginada( IntToStr( intlimite + 1 ) ) +'">'+ getBlogConfigItem('nextpoststr') +'</a>'
                        else
                            //cria link desabilitado
                            straux2:= straux2 + '<a disabled="true">'+ getBlogConfigItem('nextpoststr') +'</a>';

                        straux2:= straux2 + '</div>';

                        Result:= straux + straux2;
                     end
                     else begin
                         //não há posts definidos
                         Result:= '<b>Sem posts por enquanto!</b>';
                     end;

                 end; //end todos os posts


            end; //end with
        except
           on E: EDatabaseError do
           begin
            Result:= '<b>Erro na base de dados!</b> Motivo: '+ E.Message;
        	  end;
        end;
    end;
    //free memory
    TuntDB.Disconnect();
end;

class function TuntBlog.getBlogCommentCount( postid: string ): string;
var
  qryAux : TSQLQuery;
begin

    try
        qryAux := TSQLQuery.Create(nil);
        qryAux.DataBase := SQLite3Con;
        qryAux.Transaction := SQLTrans;

        with qryAux do
        begin
             Close;
             SQL.Text:= 'SELECT COUNT(idpost) AS `total` FROM tbblogpostcomments WHERE idpost='+postid+';';
             Open;

             if RecordCount > 0  then
             begin
                 Result:= FieldByName('total').AsString + ' ' + getBlogConfigItem('commentstr');
             end;
        end;

        qryAux.Destroy;

    except
    	on E: EDatabaseError do
      begin
	    Result:= '<b>Erro na base de dados!</b> Motivo: ' + E.Message;
      end;
    end;

end;

class function TuntBlog.getBlogPostTags( postid: string ): string;
var
  qryAux : TSQLQuery;
  straux: string;
begin

    try
        qryAux := TSQLQuery.Create(nil);
        qryAux.DataBase := SQLite3Con;
        qryAux.Transaction := SQLTrans;

        with qryAux do
        begin
             Close;
             SQL.Add('SELECT tbtag.id AS `tagId`, tbtag.name AS `tagName` ');
             SQL.Add('FROM tbblogtags AS `tbtag`,  tbblogposttags AS `tbbpt` ');
             SQL.Add('WHERE tbbpt.idcategory = tbtag.id AND tbbpt.idpost='+ postid +' ');
             SQL.Add('ORDER BY tbtag.name');
             Open;

             if RecordCount > 0  then
             begin
                straux := '';

                while not EOF do begin
				    //monsta link de cada tag (assunto) relativo ao post
                    straux:= straux + '<a href="tag='+ FieldByName('tagId').AsString +'">'+ FieldByName('tagName').AsString + '</a> ';

                    next;
                end;

                Result:= straux;
             end
             else begin
                  Result:= 'Sem Assunto';
             end;
        end;

        qryAux.Destroy;

    except
	    Result:= '<b>Não foi possível carregar os assuntos!</b>';
    end;

end;

class function TuntBlog.getBlogComments( postid: string ): string;
var
  qryAux : TSQLQuery;
  straux: string;
begin

    try
        qryAux := TSQLQuery.Create(nil);
        qryAux.DataBase := SQLite3Con;
        qryAux.Transaction := SQLTrans;

        with qryAux do
        begin
             Close;
             SQL.Add('SELECT tc.name, tc.data, tc.site, tc.message ');
             SQL.Add('FROM tbblogcomments AS `tc`, tbblogpostcomments AS `tbpc` ');
             SQL.Add('WHERE tc.id = tbpc.idcomment AND tbpc.idpost = '+ postid +' ');
             SQL.Add('ORDER BY tc.data DESC;');
             Open;

             if RecordCount > 0  then
             begin
                straux := '<ol>';

                while not EOF do begin
                    straux:= straux + '<li>';
                    //testa se o fulano tem site para gerar o link
                    if ( FieldByName('site').AsString <> EmptyStr ) then
                       straux:= straux + '<i><strong><a href="'+ FieldByName('site').AsString +'" target="new">'+ FieldByName('name').AsString +'</a></strong> em '
                    else
                       straux:= straux + '<i><strong>'+ FieldByName('name').AsString +'</strong> em ';
                    straux:= straux + FieldByName('data').AsString +'</i>:';
                    straux:= straux + '<p>'+ FieldByName('message').AsString +'</p>';

                    //fim do comentário
                    straux:= straux + '</li>';

                    next;
                end;

                //encerra lista de comentários
                straux:= straux + '</ol>';

                Result:= straux;
             end
             else begin
                  Result:= 'Ainda sem comentários, seja o primeiro!';
             end;
        end;

        qryAux.Destroy;

    except
       on E: Edatabaseerror do
       begin
           Result:= '<b>Não foi possível ler os comentários!</b> Motivo: ' + E.Message;
       end;
    end;

end;

class function TuntBlog.setBlogComment(Arequest: TRequest; db: string): boolean;
var
  straux : string;
begin
	if TuntDB.Connect( db ) then
   begin
	   try
           if Arequest.QueryFields.Values['r'] <> EmptyStr then
           begin
           		straux:= Arequest.QueryFields.Values['r'];
               if Pos('pst=', straux) > 0 then
           			Delete( straux, 1, Pos('pst=', straux)+3 );
           end
      	  else
           		straux:= Arequest.ContentFields.Values['postID'];

           with SQLQuery do
           begin
           		 Close;
                SQL.Add('INSERT INTO tbblogcomments(name, email, site, message, data) ');
                SQL.Add('VALUES(:name, :email, :site, :message, :data)');

                ParamByName('name').AsString:= ARequest.ContentFields.Values['edtNome'];
                ParamByName('email').AsString:= ARequest.ContentFields.Values['edtMail'];
                ParamByName('site').AsString:= ARequest.ContentFields.Values['edtSite'];
                ParamByName('message').AsString:= ARequest.ContentFields.Values['txtMsg'];
                ParamByName('data').AsString:= DateToStr( Now() );//FormatDateTime( 'dd-mm-yyyy', Now() );
                ExecSQL;

                //Liga o commentário ao post
                SQL.Clear;
                SQL.Add('INSERT INTO tbblogpostcomments(idpost, idcomment) ');
                SQL.Add('VALUES(:idpost, :idcomment)');

                ParamByName('idpost').AsString:= straux;
                ParamByName('idcomment').AsString:= getBlogCommentLast();
                ExecSQL;

                //realizou alterações, commit.
                SQLTrans.Commit;


                Result:= true;
           end;
	   except
      	//SQLTrans.Rollback;
         Result:= false;
	   end;
   end;

   TuntDB.Disconnect();
end;

class function TuntBlog.getBlogCommentLast: string;
var
  	qryAux: TSQLQuery;
begin
    try
        qryAux := TSQLQuery.Create(nil);
        qryAux.DataBase := SQLite3Con;
        qryAux.Transaction := SQLTrans;

        with qryAux do
        begin
             Close;
             SQL.Text:= 'SELECT seq FROM sqlite_sequence WHERE name="tbblogcomments";';
             Open;

             if RecordCount > 0  then
             begin
                 Result:= FieldByName('seq').AsString;
             end;
        end;

        qryAux.Destroy;

    except
	    Result:= '<b>Erro na base de dados!</b>';
    end;
end;

class function TuntBlog.setBlogCommentForm( postid: string ): string;
var
  straux : string;
begin
   straux:= '<div>';

   //cria form e monta o caminho correto do post
   straux:= straux + '<br/><div class="panelGreen" id="msgOk">Comentário enviado!</div>';
   straux:= straux + '<div class="panelRed" id="msgEr">Erro no envio!</div>';

   straux:= straux + '<form name="frmComment" action="comment?r='+ StringReplace(getAPPURL(), '&', '_', [rfReplaceAll] ) +'" enctype="multipart/form-data" method="post">';

   straux:= straux + '<input type="hidden" name="postID" value="'+ postid +'"/>';

   straux:= straux + '<label for="edtNome">Nome</label><br/>';
   straux:= straux + '<input id="edtNome" name="edtNome" type="text" size="60" required="required"/><br/>';

   straux:= straux + '<label for="edtMail">E-mail</label><br/>';
   straux:= straux + '<input id="edtMail" name="edtMail" type="text" size="60" required="required" placeholder="Não será publicado"/><br/>';

   straux:= straux + '<label for="edtSite">Site</label><br/>';
   straux:= straux + '<input id="edtSite" name="edtSite" type="text" size="60" placeholder="www.nomedosite.com"/><br/>';

   straux:= straux + '<label for="txtMsg">Comentário</label><br/>';
   straux:= straux + '<textarea id="txtMsg" name="txtMsg" rows="7" cols="80" required="required"></textarea><br/>';

   straux:= straux + '<input type="submit" value="comentar"/>';

   straux:= straux + '</form></div>';

   Result:= straux;
end;

class function TuntBlog.getBlogConfigItem(strItem: string) : string;
var
  qryAux : TSQLQuery;
begin

    try
        qryAux := TSQLQuery.Create(nil);
        qryAux.DataBase := SQLite3Con;
        qryAux.Transaction := SQLTrans;

        with qryAux do
        begin

             SQL.Text:= 'SELECT value FROM tbblogconfig WHERE option='''+ strItem +''' ';
             Open;

             if RecordCount > 0  then
                  Result:= FieldByName('value').AsString
             else
             	 Result:= '#blank#';
        end;
    except
        Result:= '<div class="msgError">Erro na consulta!</div>';
    end;

    qryAux.Destroy;
end;

constructor TuntBlog.Create;
begin

end;

destructor TuntBlog.Destroy;
begin
    inherited Destroy;
end;


end.

