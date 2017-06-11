unit untAdmBlog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, HTTPDefs, websession, fpHTTP, fpWeb,
  //database libs
  db, sqldb,
  //custom libs
  untAdmPage, untDB;

type

  { TuntAdmBlog }

  { TuntAdmPaginas }

  TuntAdmBlog = class(TuntAdmPage)
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

    class function exec(item: integer) : string;

    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TuntAdmPaginas }

procedure TuntAdmBlog.tagReplace(Sender: TObject; const TagString: String;
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
           ReplaceText:= 'teste';//getListMenu();
   end;

end;

class function TuntAdmBlog.exec(item: integer): string;
begin
   case item of
      //novo post
      1 : begin
         self.Form := self.FormPath + 'frmBlogPost.html';

         //if Request.QueryFields.Values['act'] = '2' then
         //msg := update(); //atualiza e carrega mensagem

         Result:= self.getHTML();
      end;

      2 : begin
         self.Form := self.FormPath + 'frmBlogListaPost.html';

         //if Request.QueryFields.Values['act'] = '2' then
         //msg := update(); //atualiza e carrega mensagem

         Result:= self.getHTML();
      end;

      //menus
      3 : begin
         self.Form := self.FormPath + 'frmBlogComentarios.html';

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

      4 : begin
         self.Form := self.FormPath + 'frmBlogCategorias.html';

         //if Request.QueryFields.Values['act'] = '2' then
         //msg := update(); //atualiza e carrega mensagem

         Result:= self.getHTML();
      end;

   end;
end;

function TuntAdmBlog.select(Sender: TObject; ARequest: TRequest;
   AResponse: TResponse; var Handled: Boolean): string;
begin

end;

function TuntAdmBlog.insert(Sender: TObject; ARequest: TRequest;
   AResponse: TResponse; var Handled: Boolean): string;
begin

end;

function TuntAdmBlog.update(Sender: TObject; ARequest: TRequest;
   AResponse: TResponse; var Handled: Boolean): string;
begin

end;

function TuntAdmBlog.delete(Sender: TObject; ARequest: TRequest;
   AResponse: TResponse; var Handled: Boolean): string;
begin

end;

function TuntAdmBlog.doSQL(action: string; sql: string): string;
begin

end;

constructor TuntAdmBlog.Create;
begin

end;

destructor TuntAdmBlog.Destroy;
begin
   inherited Destroy;
end;

end.

