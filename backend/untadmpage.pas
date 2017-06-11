unit untAdmPage;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, HTTPDefs, fpHTTP, fpWeb,
  //database libs
  db, sqldb, sqlite3conn,
  //useful for connects
  untDB;

type

  { untAdmPage }

  TuntAdmPage = class
  private
    { private declarations }
  public
    { public declarations }
    class var Database, TableName, PrimaryKey, FormPath, Form, AppURL, msg : string;
    class var Request: TRequest;
    class var WebModule : TFPWebModule;
    //
    //function getConfigItem(strItem: string) : string;
    //
    procedure tagReplace(Sender: TObject; const TagString:String;
              TagParams: TStringList; Out ReplaceText: String); virtual; abstract;
    function select(Sender: TObject; ARequest: TRequest;
          AResponse: TResponse; var Handled: Boolean) : string; virtual; abstract;
    function insert(ARequest: TRequest) : string; virtual;
    function update(Sender: TObject; ARequest: TRequest;
          AResponse: TResponse; var Handled: Boolean) : string; virtual;
    function delete(Sender: TObject; ARequest: TRequest;
          AResponse: TResponse; var Handled: Boolean) : string; virtual;
    //
    function doSQL(action:string; sql: string) : string;
    class function getHTML(): string; //Sender: TObject; Sender2: TFPWebModule; path: string) : string;
    function exec(ARequest: TRequest) : string; virtual;
    //
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ untAdmPage }

(*function TuntAdmPage.getConfigItem(strItem: string) : string;
var
  straux: string;
begin

    {
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
    }
end; *)

{function TuntAdmPage.select(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean) : string;
var
  max,i : integer;
  resp: string;
begin
     //SELECT
     max := ARequest.QueryFields.Count-1;

     resp:= 'SELECT ';
     //roda para os nomes dos campos
     for i:= 1 to max do begin
         resp := resp + ARequest.QueryFields.Names[i];
         if( i< max)then begin
              resp:= resp + ', ';
         end;
     end;

     resp := resp + ' FROM table WHERE condition;';


     AResponse.Content := resp;
end; }

{function TuntAdmPage.insert(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean) : string;}
function TuntAdmPage.insert(ARequest: TRequest): string;
begin

     {//INSERT
     if( LowerCase( ARequest.Method ) = 'get') then //via GET
     begin
       vals[1] := ARequest.QueryFields.Values['edtLogin'];
     end
     else
     begin //via POST
       vals[1] := ARequest.ContentFields.Values['edtLogin'];
     end;

     max := ARequest.QueryFields.Count-1;

     resp:= 'INSERT INTO tabela(';
     //roda para os nomes dos campos
     for i:=0 to max do begin
         resp := resp + ARequest.QueryFields.Names[i];// + '>' + ARequest.QueryFields.ValueFromIndex[i] + ' ';
         if( i< max)then begin
              resp:= resp + ', ';
         end;
     end;

     resp:= resp + ') VALUES(';
     //roda para os valores dos campos
     for i:=0 to max do begin
         resp := resp + '''' + ARequest.QueryFields.ValueFromIndex[i] + '''';
         if( i< max)then begin
              resp:= resp + ', ';
         end;
     end;

     resp:= resp + ');';}
end;

function TuntAdmPage.update(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean) : string;
begin
     {//UPDATE
     max := ARequest.QueryFields.Count-1;

     resp:= 'UPDATE tabela SET ';
     //roda para os nomes dos campos
     for i:= 1 to max do begin
         resp := resp + ARequest.QueryFields.Names[i] + '=''' + ARequest.QueryFields.ValueFromIndex[i] + '''';
         if( i< max)then begin
              resp:= resp + ', ';
         end;
     end;

     resp := resp + ' WHERE condition;';}
end;

function TuntAdmPage.delete(Sender: TObject; ARequest: TRequest;
    AResponse: TResponse; var Handled: Boolean) : string;
begin

end;

function TuntAdmPage.doSQL(action:string; sql:string):string;
begin

end;

class function TuntAdmPage.getHTML(): string;
begin
    Self.webmodule.ModuleTemplate.FileName := self.Form;
    Self.webmodule.ModuleTemplate.AllowTagParams := true;
    Self.webmodule.ModuleTemplate.OnReplaceTag := @Self.tagReplace;

    Self.webmodule.ModuleTemplate.ParamStartDelimiter := ' ';
  	Self.webmodule.ModuleTemplate.ParamEndDelimiter := '"';
  	Self.webmodule.ModuleTemplate.ParamValueSeparator := '="';

    Result := Self.webmodule.ModuleTemplate.GetContent;
end;

function TuntAdmPage.exec(ARequest: TRequest) : string;
begin
    case StrToInt( ARequest.QueryFields.Values['exec'] ) of
           1 : begin
               //Result := insert();
             end;
           2 : begin
               //Result := update();
             end;
           3 : begin
               //Result := delete();
             end;
           4 : begin
               //Result := select();
             end;
      else begin
           //default
           Result :=  getHTML(); //getHTML( Self, TPLDIR + 'frmUsuarios.html');
          end;
      end; //end case
end;

constructor TuntAdmPage.Create;
begin

    {self.WebModule.ModuleTemplate.OnReplaceTag:= @Self.tagReplace;
    self.WebModule.ModuleTemplate.FileName := Self.Form;
     }
end;

destructor TuntAdmPage.Destroy;
begin
    inherited Destroy;
end;


end.

