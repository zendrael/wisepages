unit untAdm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  //necessárias para esta unit
  dateutils, HTTPDefs, fpHTTP, fpWeb,
  //bibliotecas de banco de dados
  db, sqldb, sqlite3conn,
  //paginas para serem acessadas
  untAdmPainel, untAdmPaginas, untAdmBlog, untAdmTemas;

type

  { TuntContratos }

  TuntAdm = class
  private
    { private declarations }
  public
    { public declarations }
    class function getPage( url, pagina, item, form:string; request: TRequest; database: string; WebModule: TFPWebModule ): string;
	//function getPageItem( item:string ): string;

    constructor Create;
    destructor Destroy; override;
  end;


implementation

class function TuntAdm.getPage( url, pagina, item, form: string; request: Trequest; database: string; WebModule: TFPWebModule ): string;
var
   //objetos das páginas
	objPainel : TuntAdmPainel;
   objPaginas : TuntAdmPaginas;
   //objMidia : TuntAdmMidia;
   objBlog : TuntAdmBlog;
   //objLoja : TuntAdmLoja;
   //objPlugins : TuntAdmPlugins;
   //objAcessos : TuntAdmAcessos;
   objTemas : TuntAdmTemas;
begin
    //
    case StrToInt( pagina ) of
         //painel
    	 1 : begin
		   	   //inicializa objeto e seta configurações
               objPainel := TuntAdmPainel.Create;
               objPainel.AppURL:= url;
               objPainel.Database:= database;
               objPainel.Request := request;
               objPainel.FormPath:= form;
               objPainel.WebModule:= WebModule;
               //objTemas.WebModule.ModuleTemplate.OnReplaceTag:= @tagReplace;

               Result:= objPainel.exec( StrToInt( item ) );

               objPainel.Free;
           end;

         //páginas
         2 : begin
               //inicializa objeto e seta configurações
               objPaginas := TuntAdmPaginas.Create;
               objPaginas.AppURL:= url;
               objPaginas.Database:= database;
               objPaginas.Request := request;
               objPaginas.FormPath:= form; //'frmTemas.html';
               objPaginas.WebModule:= WebModule;

               Result:= objPaginas.exec( StrToInt( item ) );

               objPaginas.Free;
           end;

         //mídia
         3 : begin

           end;

         //blog
         4 : begin
               //inicializa objeto e seta configurações
               objBlog := TuntAdmBlog.Create;
               objBlog.AppURL:= url;
               objBlog.Database:= database;
               objBlog.Request := request;
               objBlog.FormPath:= form; //'frmTemas.html';
               objBlog.WebModule:= WebModule;

               Result:= objBlog.exec( StrToInt( item ) );

               objBlog.Free;
           end;

         //loja
         5 : begin

           end;

         //plugins
         7 : begin
               //inicializa objeto e seta configurações
               {objPlugins := TuntAdmPlugins.Create;
               objPlugins.AppURL:= url;
               objPlugins.Database:= database;
               objPlugins.Request := request;
               objPlugins.Form:= form;
               objPlugins.WebModule:= WebModule;

               Result:= objPlugins.exec( StrToInt( item ) );

               objPlugins.Free;}
           end;

         //estatísticas de acesso
         8 : begin

           end;

         //aparência
         6 : begin
               //inicializa objeto e seta configurações
               objTemas := TuntAdmTemas.Create;
               objTemas.AppURL:= url;
               objTemas.Database:= database;
               objTemas.Request := request;
               objTemas.FormPath:= form; //'frmTemas.html';
               objTemas.WebModule:= WebModule;
               //objTemas.WebModule.ModuleTemplate.OnReplaceTag:= @tagReplace;

               Result:= objTemas.exec( StrToInt( item ) );

               objTemas.Free;
           end;
    else
        begin
            //Default se nenhum item acima foi chamado
            //chamda do Home
		    //inicializa objeto e seta configurações
            objPainel := TuntAdmPainel.Create;
            objPainel.AppURL:= url;
            objPainel.Database:= database;
            objPainel.Request := request;
            objPainel.FormPath:= form;
            objPainel.WebModule:= WebModule;
            //objTemas.WebModule.ModuleTemplate.OnReplaceTag:= @tagReplace;

            Result:= objPainel.exec( StrToInt( item ) );

            objPainel.Free;
        end;//end else
    end;//end case
end;

constructor TuntAdm.Create;
begin

end;

destructor TuntAdm.Destroy;
begin
    inherited Destroy;
end;

end.

