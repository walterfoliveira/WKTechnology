program Servidor;
{$APPTYPE GUI}

uses
  Vcl.Forms,
  Web.WebReq,
  IdHTTPWebBrokerBridge,
  untMain in 'untMain.pas' {fmMain},
  untSrvServices in 'untSrvServices.pas' {SrvServices: TDSServerModule},
  untDM in 'untDM.pas' {DM: TDataModule},
  untDMW in 'untDMW.pas' {DMW: TWebModule},
  Pessoa in 'Model\Pessoa.pas',
  uDao in 'uDao.pas',
  Endereco in 'Model\Endereco.pas',
  Endereco_Integracao in 'Model\Endereco_Integracao.pas';

{$R *.res}

begin
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;
  Application.Initialize;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
