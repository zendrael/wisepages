unit untDB;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  //necessárias para esta unit
  dateutils, HTTPDefs,
  //bibliotecas de banco de dados
  sqldb, sqlite3conn;

type

  { TuntDB }
  TLoginInfo = array[1..3] of string;

  TuntDB = class
  private
    { private declarations }
  public
    { public declarations }
    class function Connect( db: string ): boolean;
    class function Disconnect(): boolean;

    class function doLogin( nome, senha, db : string ): TLoginInfo;

    class function getInfo( tpl, db:string ): string;
    class function getMenu( TagParams: Tstringlist; db:string ): string;
    class function getPage( db, key:string ): string;
    class function getPageMain( db:string ): string;

    class function getPlugin( nome, db:string ): string;

    class function getConfigItem(strItem, db: string) : string;

    constructor Create;
    destructor Destroy; override;
  end;


var
    SQLite3Con: TSQLite3Connection;
    SQLQuery: TSQLQuery;
    SQLTrans: TSQLTransaction;

implementation

class function TuntDB.Connect( db: string ): boolean;
begin

    //determina que .so ou .dll usar
    {$ifdef UNIX}
	   //SQLiteLibraryName:= './sqlite3.so';
	{$endif}

    {$ifdef Windows}
	   //SQLiteLibraryName:= './sqlite3.dll';
	{$endif}


    try
        //cria componentes
        SQLite3Con:= TSQLite3Connection.Create(nil);
        SQLQuery:= TSQLQuery.Create(nil);
        SQLTrans:= TSQLTransaction.Create(nil);

        //configura componentes
        SQLite3Con.DatabaseName:= db;

        SQLTrans.DataBase:= SQLite3Con;
    	SQLQuery.Database := SQLite3Con;
		SQLQuery.Transaction := SQLTrans;

        //ativa e faz a conexão
        SQLite3Con.Open;

        Result:= true;

    except
        Result:= false;
    end;
end;

class function TuntDB.Disconnect(): boolean;
begin
    try
        SQLite3Con.Close;

        SQLite3Con.Free;
        SQLQuery.Free;
        SQLTrans.Free;

        Result:= true;
    except
        Result:= false;
    end;
end;

class function TuntDB.doLogin( nome, senha, db: string ): TLoginInfo;
var
    vals : array[1..3] of string;
begin

    if Connect( db ) then
    begin

        try
            with SQLQuery do
            begin

                 SQL.Add('SELECT id, login, name, type ');
                 SQL.Add('FROM tbusers ');
                 SQL.Add('WHERE login=:Nome AND password=:Senha');
                 ParamByName('Nome').AsString:= nome;
                 ParamByName('Senha').AsString:= senha;
                 Open;

                 if RecordCount > 0  then
                 begin
                      vals[1] := FieldByName('id').AsString;
                      vals[2] := FieldByName('name').AsString;
                      vals[3] := FieldByName('type').AsString;

                      Result:= vals;
                 end
                 else
                 begin
                     //
                     vals[1] := 'ERROR';
                     vals[2] := 'Usuário e/ou senha incorretos!';

                     Result:= vals;
                 end;

            end;
        except
            //
            vals[1] := 'ERROR';
            vals[2] := 'Erro na base de dados!';

            Result:= vals;
        end;

    end; //end connect

    Disconnect();
end;


//Site info
class function TuntDB.getInfo( tpl, db: string ): string;
var
    straux : string;
begin

    if Connect( db ) then
    begin

        try
            with SQLQuery do
            begin

                 SQL.Add('SELECT value FROM tbsiteconfig ');
                 SQL.Add('WHERE option=''template'' OR option=''title'' OR option=''description'' OR option=''keywords'' OR option=''robots'' OR option=''rating'' ');
                 Open;

                 if RecordCount > 0  then
                 begin
                      tpl := tpl+ Fields[0].AsString; //template

                      next;
                      straux := straux + '<title>'+ Fields[0].AsString +'</title>' + sLineBreak;
                      straux := straux + '<link rel="add icon" href="'+ tpl +'/img/favicon.ico" type="image/x-icon" />' + sLineBreak;
		              straux := straux + '<link rel="shortcut icon" href="'+ tpl +'/img/favicon.ico" type="image/x-icon" />' + sLineBreak;
		              straux := straux + '<link rel="icon" href="'+ tpl +'/img/favicon.ico" type="image/ico" type="image/x-icon" />' + sLineBreak;
                      next;
                      straux := straux + '<meta name="description" content="'+ Fields[0].AsString+'"/>' + sLineBreak;
                      next;
                      straux := straux + '<meta name="keywords" content="'+ Fields[0].AsString +'"/>' + sLineBreak;
                      next;
	                  straux := straux + '<meta name="robots" content="'+ Fields[0].AsString +'"/>' + sLineBreak;
                      next;
	                  straux := straux + '<meta name="rating" content="'+ Fields[0].AsString +'"/>' + sLineBreak;
                      //next;
                      straux := straux + '<meta name="generator" content="WisePages"/>' + sLineBreak;
                      straux := straux + '<meta name="author" content="wisepages Technology"/>' + sLineBreak;


		              //<!-- css -->
		              straux := straux + '<link title="look_and_feel" rel="stylesheet" href="'+ tpl + '/css/theme.css" type="text/css">' + sLineBreak;
		              //<!-- js -->
		              straux := straux + '<script type="text/javascript" language="JavaScript1.3" src="'+ tpl +'/js/theme.js"></script>' + sLineBreak;

                      Result:= straux;
                 end
                 else
                 begin
                     //não há tema definido
                     Result:= 'blank';
                 end;

            end;
        except
            Result:= 'Erro na base de dados!';
        end;

    end; //end connect

    Disconnect();
end;

//
class function TuntDB.getMenu( TagParams: Tstringlist; db: string ): string;
var
    straux : string;
begin
    //inicializa straux para construir o menu
    straux:= '';

    //configura base e inicia conexão
    if Connect( db ) then
    begin

	    try
            with SQLQuery do
            begin

                SQL.Add('SELECT tm.id, tm.name, tm.idpage, tm.idcategory, tp.type, tp.content ');
                SQL.Add('FROM tbsitemenu AS ''tm'', tbsitepages AS ''tp'' ');
                SQL.Add('WHERE tm.idpage = tp.id ');
                SQL.Add('ORDER BY tm.posicao;');

                Open;

                if RecordCount > 0 then
                begin

                    if Trim( TagParams.Values['id'] ) <> '' then
    	               straux:= straux + ' id="'+ TagParams.Values['id'] +'" ';

		       if Trim( TagParams.Values['class'] ) <> '' then
		          straux:= straux + ' class="'+ TagParams.Values['class'] +'" ';

                          straux := '<ul'+ straux +'>';

                    while not Eof do
                    begin
		         if( FieldByName('type').AsString = 'link' ) then
                         begin
                             straux := straux + '<li><a href="'+ FieldByName('content').AsString +'" target="_new">' + FieldByName('name').AsString + '</a></li>';
                         end
                         else begin
                             straux := straux + '<li><a href="?p='+ FieldByName('idpage').AsString +'">' + FieldByName('name').AsString + '</a></li>';
                         end;

                         //necessário chamar o próximo
                         Next;
                    end;

                    straux := straux + '</ul>';

                    Result:= straux;

                end
                else
                begin
                    //não há menus definidos
                    Result:= '<ul><li><a href="#">Configure seus menus!</a></li></ul>';
                end;

                Close;

            end; //end with...
        except
        	  Result:= '<ul><li><a href="#">Erro na consulta dos menus!</a></li></ul>';
        end;

    end; //end if connect

    //encerra conexão
    Disconnect();

end;

class function TuntDB.getPage( db, key: string ): string;
var
    straux : string;
begin

    if Connect( db) then
    begin

        try
            with SQLQuery do
            begin

                 SQL.Text:= 'SELECT title, content, filename, type FROM tbsitepages WHERE id='+ key +';';
                 Open;

                 if RecordCount > 0  then
                 begin
                      straux := Trim( FieldByName('title').AsString );
                      straux := straux +'|'+ Trim( FieldByName('type').AsString );
                      straux := straux +'|'+ Trim( FieldByName('content').AsString );
                      straux := straux +'|'+ Trim( FieldByName('filename').AsString );

                      Result:=  straux;
                 end
                 else
                 begin
                     //não há páginas definidos
                     Result:= '<b>Página não encontrada!</b>';
                 end;

            end;
        except
            Result:= '<b>Erro na base de dados!</b>';
        end;

    end;

    //free memory
    Disconnect();
end;

class function TuntDB.getPageMain( db: string ): string;
var
    straux : string;
begin

    if Connect( db ) then
    begin

        try
            with SQLQuery do
            begin

                 SQL.Text:= 'SELECT value FROM tbsiteconfig WHERE option=''mainpage'';';
                 Open;

                 if RecordCount > 0  then
                 begin
                      straux:= FieldByName('value').AsString;

                      //consulta página e retorna
                      Close;
                      SQL.Text:= 'SELECT title, content, filename, type FROM tbsitepages WHERE id='+ straux +';';
             	      Open;

                      //se não houver resultado, não carregará nada na home
             	      if RecordCount > 0  then begin
                  	     if FieldByName('content').AsString = EmptyStr  then
                         begin
                  	         straux := Trim( FieldByName('title').AsString );
                  	         straux := straux +'|'+ Trim( FieldByName('type').AsString );
                  	         straux := straux +'|'+ Trim( FieldByName('content').AsString );
                  	         straux := straux +'|'+ Trim( FieldByName('filename').AsString );

                  	         Result:=  straux;
                         end else
                         begin
                             Result:=  Trim( FieldByName('content').AsString );
                         end;
                      end;
                      //
                 end
                 else
                 begin
                     //não há páginas definidos
                     Result:= '<b>Página não encontrada!</b>';
                 end;

            end;
        except
            Result:= '<b>Erro na base de dados!</b>';
        end;

    end;

    //free memory
    Disconnect();
end;

class function TuntDB.getPlugin( nome, db: string ): string;
var
    straux : string;
begin

    if Connect( db ) then
    begin

        try
            with SQLQuery do
            begin

                 SQL.Text:= 'SELECT name, language FROM tbplugins WHERE name='''+ LowerCase( nome ) +''';';
                 Open;

                 if RecordCount > 0  then
                 begin
                      straux := Trim( LowerCase( FieldByName('language').AsString ) );

                      Result:=  straux;
                 end
                 else
                 begin
                     //não há páginas definidos
                     Result:= '<b>Plugin não encontrado!</b>';
                 end;

            end;
        except
            Result:= '<b>Erro na base de dados!</b>';
        end;

    end;

    //free memory
    Disconnect();
end;

class function TuntDB.getConfigItem(strItem, db: string) : string;
begin

    if Connect( db ) then
    begin

        try
            with SQLQuery do
            begin

                 SQL.Text:= 'SELECT value FROM tbsiteconfig WHERE option='''+ strItem +''' ';
                 Open;

                 if RecordCount > 0  then
                      Result:= FieldByName('value').AsString
                 else
             	     Result:= '#blank#';
            end;
        except
            Result:= '<div class="msgError">Erro na consulta!</div>';
        end;

    end;

    Disconnect();
end;

constructor TuntDB.Create;
begin

end;

destructor TuntDB.Destroy;
begin
    inherited Destroy;
end;

end.

