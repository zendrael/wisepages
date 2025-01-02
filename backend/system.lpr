program websystem;

{$mode objfpc}{$H+}

uses
  fpCGI, fpWeb, main, untDB, untAdm, untAdmPage, untAdmPaginas, untMail,
untAdmTemas, untPlugin, untAdmPainel, untBlog, untAdmBlog;

begin
    Application.Title:='wisepages';
  Application.Initialize;
  Application.Run;
end.

