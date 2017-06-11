unit untAdmPainel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, HTTPDefs, websession, fpHTTP, fpWeb,
  //database libs
  db, sqldb, sqlite3conn,
  //custom libs
  untAdmPage, untDB;

type

  { untAdmPainel }

  TuntAdmPainel = class(TuntAdmPage)
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
    function delete(Sender: TObject; ARequest: TRequest;
          AResponse: TResponse; var Handled: Boolean) : string;

    function doSQL(action:string; sql: string):string;

    class function exec(item: integer) : string;

    class function update() : string;
    class function updateInfo() : string;

    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ untAdmPainel }

procedure TuntAdmPainel.tagReplace(Sender: TObject; const TagString: String;
    TagParams: TStringList; out ReplaceText: String);
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

  if AnsiCompareText(TagString, 'wiseUserName') = 0 then begin

        ReplaceText:= self.WebModule.Session.Variables['UNAME'];
  end;

end;

function TuntAdmPainel.select(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean) : string;
var
  max,i : integer;
  resp: string;
begin
    //
end;

function TuntAdmPainel.insert(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean) : string;
begin
    //
end;

class function TuntAdmPainel.update() : string;
var
  straux: string;
begin
  {
    dsDB := TSqlite3Dataset.Create(nil);
    try
        with dsDB do
        begin
             FileName:= self.Database;
             TableName := 'tbsiteconfig';
             PrimaryKey := 'id';
             Active:= true;
             Close;

             SQL:= 'UPDATE  '+ TableName +' SET value='''+ Request.ContentFields.Values['edtTema'] +''' WHERE option=''template'' ;';
             Open;

             Result:= '<div class="msgOk">Atualizado!</div>';
        end;
    except
        Result:= '<div class="msgError">Erro na atualização!</div>';
    end;
    }
end;

class function TuntAdmPainel.updateInfo() : string;
var
    max, i: integer;
    //straux: string;
begin

    max := Request.ContentFields.Count -1;

    //conecta e atualiza banco
    TuntDB.Connect( self.Database );

    try
        with SQLQuery do
        begin

             for i:= 0 to max do begin

                 Close;

                 //vai ser usado na sequencia, melhor limpar
                 Sql.Clear;

                 SQL.Add('UPDATE tbsiteconfig ');
                 SQL.Add('SET value='''+ Request.ContentFields.ValueFromIndex[i] +''' ');
                 SQL.Add('WHERE option='''+ Request.ContentFields.Names[i] +''' ;');

                 //straux += 'SET value='''+ Request.ContentFields.ValueFromIndex[i] + ''' - WHERE option='''+ Request.ContentFields.Names[i] +''';<br/>';
                 ExecSQL;

             	 //realizou alterações, commit.
             	 SQLTrans.Commit;

             end; //end for

             Result:= '<div class="msgOk">Atualizado!</div>'; //+ straux +'</div>';
        end;
    except
        Result:= '<div class="msgError">Erro na atualização!</div>';
    end;

    TuntDB.Disconnect();

end;

function TuntAdmPainel.delete(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean) : string;
begin

end;

function TuntAdmPainel.doSQL(action:string; sql:string):string;
begin

end;

class function TuntAdmPainel.exec(item: integer) : string;
begin
    case item of

         //inicio
    	 1 : begin

		   	 self.Form := self.FormPath + 'frmPainelInicio.html';

             Result:= self.getHTML();

           end;

         //info
         2 : begin

                //if Request.QueryFields.Values['i'] = '2' then
                //begin
                    self.Form := self.FormPath + 'frmPainelInfo.html';

                    if Request.QueryFields.Values['act'] = '2' then
                       msg := updateInfo(); //atualiza e carrega mensagem

                    Result:= self.getHTML();
                //end;

           end;

         //usuarios
         3 : begin

           end;
    else
        begin
			 self.Form := self.FormPath + 'frmPainelInicio.html';

             Result:= self.getHTML();
        end;
    end;
end;

constructor TuntAdmPainel.Create;
begin

end;

destructor TuntAdmPainel.Destroy;
begin
    inherited Destroy;
end;


end.

