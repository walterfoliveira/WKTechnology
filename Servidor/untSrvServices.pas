unit untSrvServices;

interface

uses System.SysUtils, System.Classes, System.Json,
  DataSnap.DSProviderDataModuleAdapter,

  uDao, Pessoa, Endereco, Endereco_Integracao,
  Rest.Json, Data.FireDACJSONReflect, System.StrUtils, Web.HTTPApp,
  DataSnap.DSHTTPWebBroker, System.NetEncoding,

  System.Threading,

  DataSnap.DSServer, DataSnap.DSAuth, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Stan.StorageJSON, FireDAC.UI.Intf, FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI,
  FireDAC.Stan.StorageBin, Rest.Types, Rest.Client, Data.Bind.Components,
  Data.Bind.ObjectScope, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys,
  FireDAC.Phys.PG, FireDAC.Phys.PGDef;

type
  TSrvServices = class(TDSServerModule)
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDConnection: TFDConnection;
    FDPhysPgDriverLink1: TFDPhysPgDriverLink;
  private
    { Private declarations }

    function BuscarCEP_ViaCEP(Cep: string): TStringList;

    function InsertPessoa(Pessoa: TPessoa): Integer;
    function InsertEndereco(Endereco: TEndereco): Integer;
    procedure InsertEnderecoIntegracao(Endereco: TEndereco_Integracao);
    procedure UpdateEnderecoIntegracao(Endereco: TEndereco_Integracao);

  public
    { Public declarations }

    function UpdateImportar(JsonObjArray: TJSONArray): TJSONValue; // Post
    //Modelo
    // [{"lote":[{"file":"827CCB0EEA8A706C4C34A16891F84E7B"}]}]

    function Pessoas(AId: Integer): TJSONObject; // Get
    function AcceptPessoas(JsonObj: TJSONObject): TJSONValue; // Put
    function UpdatePessoas(JsonObj: TJSONObject): TJSONValue; // Post
    function CancelPessoas(AId: Integer): TJSONValue; // Cancel


    function Endereco(AId: Integer): TJSONObject;
    function EnderecoByPessoa(AId: Integer): TJSONObject;
    function UpdateEndereco(JsonObj: TJSONObject): TJSONValue; // Post
    function AcceptEndereco(JsonObj: TJSONObject): TJSONValue; // Put
    function CancelEndereco(AId: Integer): TJSONValue; // Cancel

  end;

implementation


{$R *.dfm}
{ TSrvServices }

// Private
function TSrvServices.BuscarCEP_ViaCEP(Cep: string): TStringList;
var
  respTask: TStringList;

   Endereco: TStringList;

   RESTClient1: TRESTClient;
   RESTRequest1: TRESTRequest;
   RESTResponse1: TRESTResponse;
   objBase: TJSONObject;
begin
 RESTClient1 := TRESTClient.Create(nil);
 RESTRequest1 := TRESTRequest.Create(nil);
 RESTResponse1 := TRESTResponse.Create(nil);
 RESTRequest1.Client := RESTClient1;
 RESTRequest1.Response := RESTResponse1;
 RESTClient1.BaseURL := 'https://viacep.com.br/ws/' + Cep + '/json';

 RESTRequest1.Execute;
 objBase:= RESTResponse1.JSONValue as TJSONObject;

 try
    Endereco := TStringList.Create;
    if Assigned(objBase) then
    begin
      try
        Endereco.Add(Trim(UpperCase(objBase.Values['logradouro'].Value)));
      except
        on Exception do
          Endereco.Add('');
      end;
      try
        Endereco.Add(Trim(UpperCase(objBase.Values['bairro'].Value)));
      except
        on Exception do
          Endereco.Add('');
      end;
      try
        Endereco.Add(Trim(UpperCase(objBase.Values['uf'].Value)));
      except
        on Exception do
          Endereco.Add('');
      end;
      try
        Endereco.Add(Trim(UpperCase(objBase.Values['localidade'].Value)));
      except
        on Exception do
          Endereco.Add('');
      end;
      try
        Endereco.Add(Trim(UpperCase(objBase.Values['complemento'].Value)));
      except
        on Exception do
          Endereco.Add('');
      end;
    end;
  finally
    if Assigned(objBase) then
     FreeAndNil(objBase);
    FreeAndNil(RESTClient1);
    FreeAndNil(RESTRequest1);
 end;

 Result:= Endereco;

end;

procedure TSrvServices.UpdateEnderecoIntegracao(Endereco: TEndereco_Integracao);

begin
  TThread.Synchronize(TThread.CurrentThread,
    procedure
    Var
      qryTemp: TFDQuery;
      TConexao: TDao;
    begin
      TConexao := TDao.Create;
      qryTemp := TFDQuery.Create(TConexao.Connection);

      try
        qryTemp.Connection := TConexao.Connection;

        qryTemp.Close;
        qryTemp.SQL.Clear;
        qryTemp.SQL.Add
          ('Update Endereco_Integracao Set dsuf = :dsuf, nmcidade = :nmcidade, nmbairro = :nmbairro, nmlogradouro = :nmlogradouro, dscomplemento = :dscomplemento Where idendereco = :idendereco');

        qryTemp.ParamByName('idendereco').AsInteger := Endereco.idendereco;
        qryTemp.ParamByName('dsuf').AsString := Endereco.dsuf;
        qryTemp.ParamByName('nmcidade').AsString := Endereco.nmcidade;
        qryTemp.ParamByName('nmbairro').AsString := Endereco.nmbairro;
        qryTemp.ParamByName('nmlogradouro').AsString := Endereco.nmlogradouro;
        qryTemp.ParamByName('dscomplemento').AsString := Endereco.dscomplemento;
        qryTemp.ExecSQL();

      finally
        Endereco.Free;
        qryTemp.Free;
        TConexao.Free;
      end;
    end);
end;

procedure TSrvServices.InsertEnderecoIntegracao(Endereco: TEndereco_Integracao);

begin
  TThread.Synchronize(TThread.CurrentThread,
    procedure
    Var
      qryTemp: TFDQuery;
      TConexao: TDao;
    begin
      TConexao := TDao.Create;
      qryTemp := TFDQuery.Create(TConexao.Connection);

      try
        qryTemp.Connection := TConexao.Connection;

        qryTemp.Close;
        qryTemp.SQL.Clear;
        qryTemp.SQL.Add
          ('Insert Into Endereco_Integracao (idendereco, dsuf, nmcidade, nmbairro, nmlogradouro, dscomplemento) Values (:idendereco, :dsuf, :nmcidade, :nmbairro, :nmlogradouro, :dscomplemento)');

        qryTemp.ParamByName('idendereco').AsInteger := Endereco.idendereco;
        qryTemp.ParamByName('dsuf').AsString := Endereco.dsuf;
        qryTemp.ParamByName('nmcidade').AsString := Endereco.nmcidade;
        qryTemp.ParamByName('nmbairro').AsString := Endereco.nmbairro;
        qryTemp.ParamByName('nmlogradouro').AsString := Endereco.nmlogradouro;
        qryTemp.ParamByName('dscomplemento').AsString := Endereco.dscomplemento;
        qryTemp.ExecSQL();

      finally
        Endereco.Free;
        qryTemp.Free;
        TConexao.Free;
      end;
    end);
end;

function TSrvServices.InsertEndereco(Endereco: TEndereco): Integer;
Var
  idEndereco: Integer;
  qryTemp: TFDQuery;
  TConexao: TDao;

  EnderecoStrList: TStringList;
  EnderecoIntegracao: TEndereco_Integracao;
begin

  TThread.Synchronize(TThread.CurrentThread,
    procedure
    begin

      TConexao := TDao.Create;
      qryTemp := TFDQuery.Create(TConexao.Connection);

      try
        qryTemp.Connection := TConexao.Connection;

        qryTemp.Close;
        qryTemp.SQL.Clear;
        qryTemp.SQL.Add
          ('Insert Into endereco (idpessoa, dscep) Values (:idpessoa, :dscep)');

        qryTemp.ParamByName('idpessoa').AsInteger := Endereco.idpessoa;
        qryTemp.ParamByName('dscep').AsString := Endereco.dscep;
        qryTemp.ExecSQL();

        if (qryTemp.RowsAffected > 0) then
        begin
          // Pega ID do Endereco
          qryTemp.Close;
          qryTemp.SQL.Clear;
          qryTemp.SQL.Add('Select Max(idendereco) as id from endereco');
          qryTemp.Open;
          idEndereco:= qryTemp.fieldByName('id').AsInteger;

          // Consulta o CEP
          EnderecoStrList := BuscarCEP_ViaCEP(Endereco.dscep);
          if EnderecoStrList.Count = 5 then
          begin
            EnderecoIntegracao := TEndereco_Integracao.Create;
            EnderecoIntegracao.idendereco := idEndereco;
            EnderecoIntegracao.nmlogradouro := EnderecoStrList[0];
            EnderecoIntegracao.nmbairro := EnderecoStrList[1];
            EnderecoIntegracao.dsuf := EnderecoStrList[2];
            EnderecoIntegracao.nmcidade := EnderecoStrList[3];
            EnderecoIntegracao.dscomplemento := EnderecoStrList[4];

            // Insere Enderece integracao
            InsertEnderecoIntegracao(EnderecoIntegracao);
          end;

        end;

      finally
        Endereco.Free;
        qryTemp.Free;
        TConexao.Free;
      end;
 end);
 Result:= idEndereco;
end;

function TSrvServices.InsertPessoa(Pessoa: TPessoa): Integer;
Var
  qryTemp: TFDQuery;
  TConexao: TDao;
begin

  TConexao := TDao.Create;
  qryTemp := TFDQuery.Create(TConexao.Connection);

  try
    qryTemp.Connection := TConexao.Connection;

    qryTemp.Close;
    qryTemp.SQL.Clear;
    qryTemp.SQL.Add
      ('Insert Into pessoa (flnatureza, dsdocumento, nmprimeiro, nmsegundo, dtregistro) Values (:flnatureza, :dsdocumento, :nmprimeiro, :nmsegundo, :dtregistro)');

    qryTemp.ParamByName('dtregistro').AsDateTime := Date;
    qryTemp.ParamByName('flnatureza').AsInteger := Pessoa.flnatureza;
    qryTemp.ParamByName('dsdocumento').AsString := Pessoa.dsdocumento;
    qryTemp.ParamByName('nmprimeiro').AsString := Pessoa.nmprimeiro;
    qryTemp.ParamByName('nmsegundo').AsString := Pessoa.nmsegundo;
    qryTemp.ExecSQL();

    Result := 0;
    if (qryTemp.RowsAffected > 0) then
    begin
      qryTemp.Close;
      qryTemp.SQL.Clear;
      qryTemp.SQL.Add('Select Max(idpessoa) as id from pessoa');
      qryTemp.Open;
      Result := qryTemp.fieldByName('id').AsInteger;
    end;

  finally
    Pessoa.Free;
    qryTemp.Free;
    TConexao.Free;
  end;

end;



// Obj: Importar em Lote
function TSrvServices.UpdateImportar(JsonObjArray: TJSONArray): TJSONValue;
Var
  lModulo: TWebModule;
  lJARequisicao: TJSONArray;
  jFile, LValores: TJSONValue;
  StreamIn: TStream;
  StreamOut: TMemoryStream;
  Cont, I: Integer;

  Task: ITask;
begin
 try

    lModulo := GetDataSnapWebModule;
    lJARequisicao := TJSONObject.ParseJSONValue
      (TEncoding.ASCII.GetBytes(lModulo.Request.Content), 0) as TJSONArray;

      for LValores in lJARequisicao do
      begin
        jFile := LValores.GetValue<TJSONArray>('lote');
        for I := 0 to Pred((jFile as TJSONArray).Count) do
        begin

          // Tratamento do FILE
          StreamIn := TStringStream.Create((jFile as TJSONArray)
            .Items[I].GetValue<string>('file'));
          StreamIn.Position := 0;
          StreamOut := TMemoryStream.Create;

          TNetEncoding.Base64.Decode(StreamIn, StreamOut);
          StreamOut.Position := 0;

          if (FileExists('importarTXT.txt')) then
           DeleteFile('importarTXT.txt');

          StreamOut.SaveToFile('importarTXT.txt');
        end;

      end;

      if (FileExists('importarTXT.txt')) then
      begin
        Cont:= 0;
        Task:= TTask.Create(
          procedure
          var
            arqFileTxt: TextFile;
            linhaTxt, cepTxt: String;
            idPessoa, PosBarra: Integer;

            Pessoa: TPessoa;
            Endereco: TEndereco;

         begin
          AssignFile(arqFileTxt, 'importarTXT.txt');
          Reset(arqFileTxt);
          while not Eof(arqFileTxt) do
          begin

            Inc(Cont);

            Pessoa := TPessoa.Create;
            ReadLn(arqFileTxt, linhaTxt);
            // formato do TXT: 1|1234|NEUZA FARIA|OLIVEIRA|09431300

            //Preenche OBJ Pessoa
            PosBarra := Pos('|', linhaTxt);
            Pessoa.flnatureza := StrToInt(Copy(linhaTxt, 1, PosBarra - 1));
            Delete(linhaTxt, 1, PosBarra);

            PosBarra := Pos('|', linhaTxt);
            Pessoa.dsdocumento := Copy(linhaTxt, 1, PosBarra - 1);
            Delete(linhaTxt, 1, PosBarra);

            PosBarra := Pos('|', linhaTxt);
            Pessoa.nmprimeiro := Copy(linhaTxt, 1, PosBarra - 1);
            Delete(linhaTxt, 1, PosBarra);

            PosBarra := Pos('|', linhaTxt);
            Pessoa.nmsegundo := Copy(linhaTxt, 1, PosBarra - 1);
            Delete(linhaTxt, 1, PosBarra);

            cepTxt := linhaTxt;

            if (cepTxt <> EmptyStr) then
            begin

              //Insert Pessoa pegando ID
              idPessoa := InsertPessoa(Pessoa);

              TThread.Synchronize(TThread.CurrentThread,
                procedure
                begin
                    // Insert Endereco
                    if (idPessoa > 0) then
                    begin
                      Endereco := TEndereco.Create;
                      Endereco.idpessoa := idpessoa;
                      Endereco.dscep := cepTxt;

                      InsertEndereco(Endereco);
                    end;
                end);
            end;

          end;

          CloseFile(arqFileTxt);
         end);

  Task.Start;
  TTask.WaitForAll(Task);
 end;

 Result := TJSONString.Create(IfThen(Cont > 0, 'true', 'false'));

finally
 StreamOut.Free;
 StreamIn.Free;
end;
end;

// Obj: Pessoa
function TSrvServices.Pessoas(AId: Integer): TJSONObject;

Var
  qryTemp: TFDQuery;
  TConexao: TDao;

  jsonArray: TJSONArray;
  JsonObj: TJSONObject;
  Pessoa: TPessoa;
begin

  Pessoa:= TPessoa.Create;
  TConexao := TDao.Create;
  qryTemp := TFDQuery.Create(TConexao.Connection);
  jsonArray := TJSONArray.Create;

  try
    qryTemp.Connection := TConexao.Connection;
    qryTemp.Close;
    qryTemp.SQL.Clear;
    qryTemp.SQL.Add('Select * from pessoa Where idpessoa = :idpessoa');
    qryTemp.ParamByName('idpessoa').AsInteger := AId;
    qryTemp.Open();

    Pessoa.idpessoa:= qryTemp.fieldByName('idpessoa').AsInteger;
    Pessoa.flnatureza:= qryTemp.fieldByName('flnatureza').AsInteger;
    Pessoa.dsdocumento:= qryTemp.fieldByName('dsdocumento').AsString;
    Pessoa.nmprimeiro:= qryTemp.fieldByName('nmprimeiro').AsString;
    Pessoa.nmsegundo:= qryTemp.fieldByName('nmsegundo').AsString;
    Pessoa.dtregistro:= DateToStr(qryTemp.fieldByName('dtregistro').AsDateTime);

    Result := TJson.ObjectToJsonObject(Pessoa);

  finally
    qryTemp.Close;
    qryTemp.Free;
    TConexao.Free;
  end;

end;

function TSrvServices.AcceptPessoas(JsonObj: TJSONObject): TJSONValue;
Var
  qryTemp: TFDQuery;
  TConexao: TDao;
  Pessoa: TPessoa;
begin

  TConexao := TDao.Create;
  qryTemp := TFDQuery.Create(TConexao.Connection);
  Pessoa := TJson.JsonToObject<TPessoa>(JsonObj.ToJSON());

  try
    qryTemp.Connection := TConexao.Connection;

    qryTemp.Close;
    qryTemp.SQL.Clear;
    qryTemp.SQL.Add
      ('Update pessoa Set flnatureza = :flnatureza, dsdocumento = :dsdocumento, nmprimeiro = :nmprimeiro, nmsegundo = :nmsegundo Where idpessoa = :idpessoa');

    qryTemp.ParamByName('idpessoa').AsInteger := Pessoa.idpessoa;
    qryTemp.ParamByName('flnatureza').AsInteger := Pessoa.flnatureza;
    qryTemp.ParamByName('dsdocumento').AsString := Pessoa.dsdocumento;
    qryTemp.ParamByName('nmprimeiro').AsString := Pessoa.nmprimeiro;
    qryTemp.ParamByName('nmsegundo').AsString := Pessoa.nmsegundo;
    qryTemp.ExecSQL();

    Result := TJSONString.Create(IfThen(qryTemp.RowsAffected > 0, 'true', 'false'));

  finally
    Pessoa.Free;
    qryTemp.Free;
    TConexao.Free;
  end;
end;

function TSrvServices.UpdatePessoas(JsonObj: TJSONObject): TJSONValue;
Var
  Pessoa: TPessoa;
  Id: Integer;
begin
  Pessoa := TJson.JsonToObject<TPessoa>(JsonObj.ToJSON());
  Id:= InsertPessoa(Pessoa);
  Result := TJSONString.Create(Id.ToString);
end;

function TSrvServices.CancelPessoas(AId: Integer): TJSONValue;
Var
  qryTemp: TFDQuery;
  TConexao: TDao;
begin

  TConexao := TDao.Create;
  qryTemp := TFDQuery.Create(TConexao.Connection);

  try
    qryTemp.Connection := TConexao.Connection;

    qryTemp.Close;
    qryTemp.SQL.Clear;
    qryTemp.SQL.Add('Delete from pessoa Where idpessoa = :idpessoa');
    qryTemp.ParamByName('idpessoa').AsInteger := AId;
    qryTemp.ExecSQL();

    Result := TJSONString.Create(IfThen(qryTemp.RowsAffected > 0, 'true',
      'false'));

  finally
    qryTemp.Free;
    TConexao.Free;
  end;

end;



// Obj: Endereco
function TSrvServices.EnderecoByPessoa(AId: Integer): TJSONObject;
Var
  Endereco: TEndereco;

  qryTemp: TFDQuery;
  TConexao: TDao;

begin

  TConexao := TDao.Create;
  qryTemp := TFDQuery.Create(TConexao.Connection);
  Endereco := TEndereco.Create;

  try
    qryTemp.Connection := TConexao.Connection;
    qryTemp.Close;
    qryTemp.SQL.Clear;
    qryTemp.SQL.Add('Select * from endereco Where idpessoa = :idPessoa');
    qryTemp.ParamByName('idPessoa').AsInteger := AId;
    qryTemp.Open();

    if (qryTemp.IsEmpty) then
    begin
      Result := TJSONObject.Create;
      Result.AddPair('mensagem', 'Endereco por pessoa n�o encontrado!');
      exit;
    end;

    Endereco.idendereco := qryTemp.fieldByName('idendereco').AsInteger;
    Endereco.idpessoa := qryTemp.fieldByName('idpessoa').AsInteger;
    Endereco.dscep := qryTemp.fieldByName('dscep').AsString;

    Result := TJson.ObjectToJsonObject(Endereco);

  finally
    qryTemp.Free;
    TConexao.Free;
  end;

end;

function TSrvServices.Endereco(AId: Integer): TJSONObject;
Var
  Endereco: TEndereco;

  qryTemp: TFDQuery;
  TConexao: TDao;

begin

  TConexao := TDao.Create;
  qryTemp := TFDQuery.Create(TConexao.Connection);
  Endereco := TEndereco.Create;

  try
    qryTemp.Connection := TConexao.Connection;
    qryTemp.Close;
    qryTemp.SQL.Clear;
    qryTemp.SQL.Add('Select * from endereco Where idendereco = :idEndereco');
    qryTemp.ParamByName('idEndereco').AsInteger := AId;
    qryTemp.Open();

    if (qryTemp.IsEmpty) then
    begin
      Result := TJSONObject.Create;
      Result.AddPair('mensagem', 'Endereco n�o encontrado!');
      exit;
    end;

    Endereco.idendereco := qryTemp.fieldByName('idendereco').AsInteger;
    Endereco.idpessoa := qryTemp.fieldByName('idpessoa').AsInteger;
    Endereco.dscep := qryTemp.fieldByName('dscep').AsString;

    Result := TJson.ObjectToJsonObject(Endereco);

  finally
    qryTemp.Free;
    TConexao.Free;
  end;

end;

function TSrvServices.UpdateEndereco(JsonObj: TJSONObject): TJSONValue;
Var
 Id: Integer;
 Endereco: TEndereco;
begin
  Endereco:= TJson.JsonToObject<TEndereco>(JsonObj.ToJSON());
  Id:= InsertEndereco(Endereco);
  Result := TJSONString.Create(Id.ToString);
end;

function TSrvServices.AcceptEndereco(JsonObj: TJSONObject): TJSONValue;
Var
  qryTemp: TFDQuery;
  TConexao: TDao;
  Endereco: TEndereco;
  EnderecoIntegracao: TEndereco_Integracao;

  EnderecoStrList: TStringList;
begin

  TConexao:= TDao.Create;
  qryTemp:= TFDQuery.Create(TConexao.Connection);
  Endereco:= TJson.JsonToObject<TEndereco>(JsonObj.ToJSON());

  try
    qryTemp.Connection := TConexao.Connection;

    qryTemp.Close;
    qryTemp.SQL.Clear;
    qryTemp.SQL.Add('Update endereco Set idpessoa = :idpessoa, dscep = :dscep Where idendereco = :idendereco');
    qryTemp.ParamByName('idendereco').AsInteger := Endereco.idendereco;
    qryTemp.ParamByName('idpessoa').AsInteger := Endereco.idpessoa;
    qryTemp.ParamByName('dscep').AsString := Endereco.dscep;
    qryTemp.ExecSQL();

    // Consulta o CEP
    EnderecoStrList := BuscarCEP_ViaCEP(Endereco.dscep);
    if EnderecoStrList.Count = 5 then
    begin
      EnderecoIntegracao := TEndereco_Integracao.Create;
      EnderecoIntegracao.idendereco := Endereco.idendereco;
      EnderecoIntegracao.nmlogradouro := EnderecoStrList[0];
      EnderecoIntegracao.nmbairro := EnderecoStrList[1];
      EnderecoIntegracao.dsuf := EnderecoStrList[2];
      EnderecoIntegracao.nmcidade := EnderecoStrList[3];
      EnderecoIntegracao.dscomplemento := EnderecoStrList[4];

      // Atualiza o Endereco integracao
      UpdateEnderecoIntegracao(EnderecoIntegracao);
    end;

    Result := TJSONString.Create(IfThen(qryTemp.RowsAffected > 0, 'true',
      'false'));

  finally
    //Endereco.Free;
    qryTemp.Free;
    TConexao.Free;
  end;
end;

function TSrvServices.CancelEndereco(AId: Integer): TJSONValue;
Var
  qryTemp: TFDQuery;
  TConexao: TDao;
begin

  TConexao := TDao.Create;
  qryTemp := TFDQuery.Create(TConexao.Connection);

  try
    qryTemp.Connection := TConexao.Connection;

    qryTemp.Close;
    qryTemp.SQL.Clear;
    qryTemp.SQL.Add('Delete from endereco Where idendereco = :idendereco');
    qryTemp.ParamByName('idendereco').AsInteger := AId;
    qryTemp.ExecSQL();

    Result := TJSONString.Create(IfThen(qryTemp.RowsAffected > 0, 'true',
      'false'));

  finally
    qryTemp.Free;
    TConexao.Free;
  end;

end;

end.
