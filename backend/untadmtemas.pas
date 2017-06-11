unit untAdmTemas;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, HTTPDefs, websession, fpHTTP, fpWeb,
  //database libs
  db, sqldb, sqlite3conn,
  //custom libs
  untAdmPage, untDB;

type

  { TuntAdmTemas }

  TuntAdmTemas = class(TuntAdmPage)
  private
    { private declarations }
    procedure tagReplace(Sender: TObject; const TagString:String;
              TagParams: TStringList; Out ReplaceText: String); override;

    //function getConfigItem(strItem: string) : string;
  public
    { public declarations }
    function select(Sender: TObject; ARequest: TRequest;
          AResponse: TResponse; var Handled: Boolean) : string;
    function insert(Sender: TObject; ARequest: TRequest;
          AResponse: TResponse; var Handled: Boolean) : string;
    class function update() : string;
    function delete(Sender: TObject; ARequest: TRequest;
          AResponse: TResponse; var Handled: Boolean) : string;
    function doSQL(action:string; sql: string):string;
    //function getHTML( Sender: TFPWebModule; path: string ):string;
    class function exec(item: integer) : string;

    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TuntAdmTemas }

procedure TuntAdmTemas.tagReplace(Sender: TObject; const TagString: String;
    TagParams: TStringList; out ReplaceText: String);
begin

  if AnsiCompareText(TagString, 'wiseAdmPath') = 0 then begin

        ReplaceText:= AppURL;
  end;

  if AnsiCompareText(TagString, 'wiseMsg') = 0 then begin

        ReplaceText:= msg;
  end;

  if AnsiCompareText(TagString, 'wiseTheme') = 0 then begin

        ReplaceText:= TuntDB.getConfigItem('template', self.Database);
  end;

  if AnsiCompareText(TagString, 'wiseActivation') = 0 then begin

        ReplaceText:= TuntDB.getConfigItem('setupdate', self.Database);
  end;

end;

function TuntAdmTemas.select(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean) : string;
var
  max,i : integer;
  resp: string;
begin
    //
end;

function TuntAdmTemas.insert(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean) : string;
begin
    //
end;

class function TuntAdmTemas.update() : string;
begin

    TuntDB.Connect( self.Database );

    try
        with SQLQuery do
        begin
             Close;

             SQL.Add('UPDATE tbsiteconfig ');
             SQL.Add('SET value='''+ Request.ContentFields.Values['edtTema'] +''' ');
             SQL.Add('WHERE option=''template'' ;');

             ExecSQL;

             //realizou alterações, commit.
             SQLTrans.Commit;

             Result:= '<div class="msgOk">Atualizado!</div>';
        end;
    except
        Result:= '<div class="msgError">Erro na atualização!</div>';
    end;

    TuntDB.Disconnect();

end;

function TuntAdmTemas.delete(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean) : string;
begin

end;

function TuntAdmTemas.doSQL(action:string; sql:string):string;
begin

end;

class function TuntAdmTemas.exec(item: integer) : string;
begin
    case item of

         //novo
    	 1 : begin

           end;

         2 : begin

            if Request.QueryFields.Values['i'] = '2' then
            begin
                self.Form := self.FormPath + 'frmTemas.html';

                if Request.QueryFields.Values['act'] = '2' then
                   msg := update(); //atualiza e carrega mensagem

                Result:= self.getHTML();// update();
            end;

              //Result:= '<h1>pagina de temas</h1>' + Request.QueryFields.Values['act'];

           end;

         3 : begin

           end;
    end;
end;

constructor TuntAdmTemas.Create;
begin

end;

destructor TuntAdmTemas.Destroy;
begin
    inherited Destroy;
end;


end.

