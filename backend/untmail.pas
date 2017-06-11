unit untMail;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  //extra units
  smtpsend, pop3send, ssl_openssl,
  //units do sistema
  untDB;

type

  ESMTP = class (Exception);
  { untMail }

  TuntMail = class
  private
    { private declarations }
  public
    { public declarations }
    class function sendMail(strQuem, strAssunto, strMensagem, base: string) : boolean;
    //class procedure MailSend(const sSmtpHost, sSmtpPort, sSmtpUser, sSmtpPasswd, sFrom, sTo, sFileName: AnsiString);
    //class procedure MailSend(const sSmtpHost, sSmtpPort, sSmtpUser, sSmtpPasswd, sTo, sFrom, sSubject, sMessage: AnsiString);

    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TuntMail }

class function TuntMail.sendMail(strQuem, strAssunto, strMensagem, base: string) : boolean;
var
  strEmail: string;
  strHost,strPort,strUser,strPass, strTls,strSsl,strStartTls: string;

  smtp: TSMTPSend;
  msg_lines: TStringList;
begin

  msg_lines := TStringList.Create;
  smtp := TSMTPSend.Create;

    //pega informações do banco de dados
    //server :=  TuntDB.getConfigItem('domain', base );
	strEmail :=  TuntDB.getConfigItem('email', base );

    strHost :=  TuntDB.getConfigItem('smtpHost', base );
    strPort :=  TuntDB.getConfigItem('smtpPort', base );
    strUser :=  TuntDB.getConfigItem('smtpUser', base );
    strPass :=  TuntDB.getConfigItem('smtpPass', base );
    strTls :=  TuntDB.getConfigItem('smtpAutoTLS', base );
    strSsl :=  TuntDB.getConfigItem('smtpFullSSL', base );
    strStartTls :=  TuntDB.getConfigItem('smtpStartTLS', base );

  try

    msg_lines.Text:= UTF8Decode( strMensagem );
    msg_lines.Insert(0, 'From: ' + strQuem );
    msg_lines.Insert(1, 'To: ' + strEmail );
    msg_lines.Insert(2, 'Reply-To: ' + strQuem );
    msg_lines.Insert(3, 'Subject: ' + strAssunto );
    //msg_lines.Insert(4, sMessage );

    smtp.UserName := strUser;
    smtp.Password := strPass;

    smtp.TargetHost := strHost;
    smtp.TargetPort := strPort;

    smtp.AutoTLS    := StrToBool( strTls );
    smtp.FullSSL    := StrToBool( strSsl );


    //AddToLog('SMTP Login');
    if not smtp.Login() then
      raise ESMTP.Create('SMTP ERROR: Login:' + smtp.EnhCodeString);

    //AddToLog('SMTP StartTLS');
    if StrToBool( strStartTls ) then
       if not smtp.StartTLS() then
       	  raise ESMTP.Create('SMTP ERROR: StartTLS:' + smtp.EnhCodeString);

    //AddToLog('SMTP Mail');
    if not smtp.MailFrom( strQuem, Length( strQuem ) ) then
      raise ESMTP.Create('SMTP ERROR: MailFrom:' + smtp.EnhCodeString);

    if not smtp.MailTo( strEmail ) then
      raise ESMTP.Create('SMTP ERROR: MailTo:' + smtp.EnhCodeString);

    if not smtp.MailData( msg_lines ) then
      raise ESMTP.Create('SMTP ERROR: MailData:' + smtp.EnhCodeString);

    //AddToLog('SMTP Logout');
    if not smtp.Logout() then
      raise ESMTP.Create('SMTP ERROR: Logout:' + smtp.EnhCodeString);
    //AddToLog('OK!');

  finally
    msg_lines.Free;
    smtp.Free;

    Result:= True;
  end;
end;

constructor TuntMail.Create;
begin

end;

destructor TuntMail.Destroy;
begin
    inherited Destroy;
end;

end.

