unit untPlugin;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  //
  HTTPDefs, httpsend, strutils,
  //
  untDB;

type
  { untPlugin }

  TuntPlugin = class
  private
    { private declarations }
  public
    { public declarations }
    class function getPlugin(name, params: string; ARequest: TRequest; base:string): string;

    constructor Create;
    destructor Destroy; override;
  end;


implementation

{TuntPlugin}

class function TuntPlugin.getPlugin(name, params: string; ARequest: TRequest; base:string) : string;
var
   strResponse : TStrings;
   server, straux : string;
begin
    //Result:= 'chamou!' + name +' - '+ params;

    //prepara resposta
    strResponse:= TStringList.Create;

    //pega plugin por nome e linguagem

    //monta string do server
    server:= ARequest.Server;
    //necessário remover parametros se já na URL
    straux := ARequest.URL;
	Delete( straux, Pos('?', straux), Length( straux ) );
    //continua concatenando a string...
    server:= server + straux + 'sys.tpl/';
    server:= server + TuntDB.getConfigItem('template', base ) + '/plgn/';
    server:= server + name + '/main.';

    server:= server + TuntDB.getPlugin( name, base );
    //se params não for vazio...
    //if ( (params <> '') and (params <> nil) ) then
       server:= server + '?' + params + '&' + ARequest.QueryString;

    //HttpGetText('http://'+ ARequest.Server+'/wisepages/sys.tpl/temared/plgn/'+ name +'/main.php?'+params+'&'+ARequest.QueryString, strResponse);
    if HttpGetText('http://'+ server, strResponse) then
    begin
		 //retorna
    	 Result:= strResponse.Text;
    end
    else begin
         //retorna erro
    	 Result:= '<b>Não foi possível carregar o plugin!</b>';
    end;

    //limpa memória
    strResponse.Free;
end;

constructor TuntPlugin.Create;
begin

end;

destructor TuntPlugin.Destroy;
begin
    inherited Destroy;
end;

end.

