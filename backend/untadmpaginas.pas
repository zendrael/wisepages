unit untAdmPaginas;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, HTTPDefs, websession, fpHTTP, fpWeb,
  //database libs
  db, sqldb,
  //custom libs
  untAdmPage, untDB;

type

  { TuntAdmPaginas }

  TuntAdmPaginas = class(TuntAdmPage)
  private
    { private declarations }
    procedure tagReplace(Sender: TObject; const TagString:String;
              TagParams: TStringList; Out ReplaceText: String); override;
  public
    { public declarations }
    function select(Sender: TObject; ARequest: TRequest;
          AResponse: TResponse; var Handled: Boolean) : string;
    function insert(Sender: TObject; ARequest: TRequest;
          AResponse: TResponse; var Handled: Boolean) : string;
    function update(Sender: TObject; ARequest: TRequest;
          AResponse: TResponse; var Handled: Boolean) : string;
    function delete(Sender: TObject; ARequest: TRequest;
          AResponse: TResponse; var Handled: Boolean) : string;
    function doSQL(action:string; sql: string):string;

    function getListMenu(): string;

    class function exec(item: integer) : string;

    class function getPageType( item: integer) : string;
    class function getPageReference( item: integer) : string;

    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TuntAdmPaginas }

procedure TuntAdmPaginas.tagReplace(Sender: TObject; const TagString: String;
    TagParams: TStringList; out ReplaceText: String);
var
  straux : string;
begin

    if AnsiCompareText(TagString, 'wiseAdmPath') = 0 then begin

        ReplaceText:= AppURL;
  end;

  if AnsiCompareText(TagString, 'wiseMsg') = 0 then begin

        ReplaceText:= msg;
  end;

  if AnsiCompareText(TagString, 'wiseConfigItem') = 0 then begin

        ReplaceText:= TuntDB.getConfigItem( TagParams.Values['get'], self.Database);
  end;

  if AnsiCompareText(TagString, 'wiseList') = 0 then begin
        if AnsiCompareText( LowerCase( TagParams.Values['type'] ), 'menu') = 0 then
           ReplaceText:= getListMenu();

        if AnsiCompareText( LowerCase( TagParams.Values['type'] ), 'page') = 0 then
           ReplaceText:= 'paginas'; //lista paginas

        if AnsiCompareText( LowerCase( TagParams.Values['type'] ), 'tipo') = 0 then
           ReplaceText:= '<option>tipos</option>'; //tipos

        if AnsiCompareText( LowerCase( TagParams.Values['type'] ), 'referencia') = 0 then
           ReplaceText:= '<option>referencias</option>'; //referencias

  end;

end;

function TuntAdmPaginas.getListMenu(): string;
var
  strAux: string;
begin
    TuntDB.Connect( Self.Database );

    try
        with SQLQuery do
        begin
             Close;

             SQL.Add('SELECT id, name, idpage, idcategory, posicao FROM tbsitemenu ORDER BY posicao ;');
             Open;

             if RecordCount > 0  then
             begin
                  //roda os resultados
                  while not EOF do
                  begin
                     straux := straux + '<tr>'+
					        '<td>'+ FieldByName('name').AsString  +'</td>'+
					        '<td>'+ getPageType( FieldByName('idpage').AsInteger ) +'</td>'+
					        '<td>'+ getPageReference( FieldByName('idpage').AsInteger ) +'</td>'+
                            '<td>'+ FieldByName('posicao').AsString +'º</td>'+
					        '<td>'+
                            	   '<a href="#" onclick="pageMenusEdit( '+
                                   	   FieldByName('idpage').AsString +','+
                                       QuotedStr( FieldByName('name').AsString ) +','+
                                       QuotedStr( getPageType( FieldByName('idpage').AsInteger ) ) +','+
                                       QuotedStr( getPageReference( FieldByName('idpage').AsInteger ) ) +','+
                                       FieldByName('posicao').AsString + ' );">'+
                                   	   '<img src="sys.img/edit.png"/>'+
                                   '</a>'+
                            '</td>'+
					        '<td>'+
                                   '<a href="#" onclick="pageMenusDelete( '+ FieldByName('idpage').AsString +' );">'+
                                   	   '<img src="sys.img/delete.png"/>'+
                                   '</a>'+
                            '</td>'+
				        '</tr>';

                     next;
                  end;
             end
             else
             begin
                 //usuário e/ou senha incorretos
                 Result:= 'Sem itens de menu.';
             end;

        end;

        Result:= strAux;
    except
        Result:= 'Erro na base de dados!';
    end;

    TuntDB.Disconnect();
end;

function TuntAdmPaginas.select(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean) : string;
var
  max,i : integer;
  resp: string;
begin
    //
end;

function TuntAdmPaginas.insert(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean) : string;
begin
    //
end;

function TuntAdmPaginas.update(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean) : string;
begin
    //
end;

function TuntAdmPaginas.delete(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean) : string;
begin

end;

function TuntAdmPaginas.doSQL(action:string; sql:string):string;
begin

end;

class function TuntAdmPaginas.exec(item: integer) : string;
var
  straux: string;
begin
    case item of
         //nova pagina
    	 1 : begin
                self.Form := self.FormPath + 'frmPaginasNova.html';

                //if Request.QueryFields.Values['act'] = '2' then
                   //msg := update(); //atualiza e carrega mensagem

                Result:= self.getHTML();
           end;

         2 : begin
                self.Form := self.FormPath + 'frmPaginasLista.html';

                //if Request.QueryFields.Values['act'] = '2' then
                   //msg := update(); //atualiza e carrega mensagem

                Result:= self.getHTML();
           end;

         //menus
         3 : begin
           	     self.Form := self.FormPath + 'frmPaginasMenus.html';

                 if Request.QueryFields.Values['act'] = '1' then
			 	    msg := 'inserir...' //insert()
                 else
                 if Request.QueryFields.Values['act'] = '2' then
                   msg := 'atualizar...'// update()
                 else
                 if Request.QueryFields.Values['act'] = '3' then
                   msg := 'apagar...';// delete();

                 Result:= self.getHTML();
           end;
    end;
end;

class function TuntAdmPaginas.getPageType( item: integer) : string;
var
   qryAux : TSQLQuery;
begin
    //TuntDB.Connect( Self.Database );

    try
        qryAux := TSQLQuery.Create(nil);
        qryAux.DataBase := SQLite3Con;
        qryAux.Transaction := SQLTrans;

        with qryAux do
        begin
             Close;
             SQL.Add('SELECT id, filename, type FROM tbsitepages WHERE id='+ IntToStr(item) +' ;');
             Open;

             if RecordCount > 0  then
             begin
                  if FieldByName('type').AsString = 'file' then Result:= 'Arquivo';
                  if FieldByName('type').AsString = 'page' then Result:= 'Interno';
                  if FieldByName('type').AsString = 'category' then Result:= 'Categoria';
                  if FieldByName('type').AsString = 'link' then Result:= 'Externo';
             end
             else
             begin
                 Result:= 'Conteúdo dinâmico';
             end;

        end;

        qryAux.Destroy;

    except
        Result:= 'Erro na base de dados!';
    end;

    //TuntDB.Disconnect();}
end;

class function TuntAdmPaginas.getPageReference( item: integer) : string;
var
   qryAux : TSQLQuery;
begin
    //TuntDB.Connect( Self.Database );

    try
        qryAux := TSQLQuery.Create(nil);
        qryAux.DataBase := SQLite3Con;
        qryAux.Transaction := SQLTrans;

        with qryAux do
        begin
             Close;

             SQL.Add('SELECT id, filename FROM tbsitepages WHERE id='+ IntToStr(item) +' ;');
             Open;

             if RecordCount > 0  then
             begin
                  Result:= FieldByName('filename').AsString;
             end
             else
             begin
                 //usuário e/ou senha incorretos
                 Result:= 'Conteúdo dinâmico';
             end;

        end;

        qryAux.Destroy;

    except
        Result:= 'Erro na base de dados!';
    end;

    //TuntDB.Disconnect();}
end;

constructor TuntAdmPaginas.Create;
begin

end;

destructor TuntAdmPaginas.Destroy;
begin
    inherited Destroy;
end;


end.

