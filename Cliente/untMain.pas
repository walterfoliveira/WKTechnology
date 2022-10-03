unit untMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Data.DB, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtDlgs,

  System.Threading, REST.Json, System.Json, System.JSON.Writers, System.NetEncoding,

  Datasnap.DBClient, Vcl.Dialogs, REST.Types, REST.Client, Data.Bind.Components,
  Data.Bind.ObjectScope, System.JSON.Types;

type
  TfmMain = class(TForm)
    PagA: TPageControl;
    TabCrud: TTabSheet;
    lblEdtNome: TLabeledEdit;
    lblEdtCpf: TLabeledEdit;
    lblEdtSobreNome: TLabeledEdit;
    Panel2: TPanel;
    btnPut: TButton;
    btnPost: TButton;
    btnDelete: TButton;
    lblEdtCep: TLabeledEdit;
    TabCarro: TTabSheet;
    DBGrid1: TDBGrid;
    Panel4: TPanel;
    btnAbrirTXT: TButton;
    OpenFile: TOpenTextFileDialog;
    cdsArquivoTXT: TClientDataSet;
    cdsArquivoTXTid: TIntegerField;
    cdsArquivoTXTdsnatureza: TIntegerField;
    cdsArquivoTXTdsdocumento: TStringField;
    cdsArquivoTXTnmprimeiro: TStringField;
    cdsArquivoTXTnmsegundo: TStringField;
    cdsArquivoTXTdscep: TStringField;
    dsArquivoTXT: TDataSource;
    btnImportar: TButton;
    rgNatureza: TRadioGroup;
    btnGet: TButton;
    edtFiltro: TEdit;
    Label1: TLabel;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    btnPutEndereco: TButton;
    procedure btnAbrirTXTClick(Sender: TObject);
    procedure btnGetClick(Sender: TObject);
    procedure btnPostClick(Sender: TObject);
    procedure btnImportarClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnPutClick(Sender: TObject);
    procedure lblEdtCpfEnter(Sender: TObject);
    procedure lblEdtCpfExit(Sender: TObject);
    procedure btnPutEnderecoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure LimparCampos;
    procedure ResetRestApiDefault;
    procedure ValidaCampos(Method: TRESTRequestMethod);
  public
    { Public declarations }
  end;

var
  fmMain: TfmMain;

implementation

uses
  Pessoa, Endereco;

{$R *.dfm}

procedure TfmMain.ValidaCampos(Method: TRESTRequestMethod);
begin

  if (Method = TRESTRequestMethod.rmGET) AND (edtFiltro.Text = EmptyStr) then
  begin
    edtFiltro.SetFocus;
    raise Exception.Create('Erro de Validação, preencha o filtro primeiro!');
  end;

  if (Method in ([TRESTRequestMethod.rmDELETE, TRESTRequestMethod.rmPUT])) AND (lblEdtCpf.Tag = 0) then
  begin
    edtFiltro.SetFocus;
    raise Exception.Create('Erro de Validação, selecionar registro primeiro!');
  end;

  if not (Method in ([TRESTRequestMethod.rmGET, TRESTRequestMethod.rmDELETE])) AND (
     (lblEdtNome.Text = EmptyStr) OR (lblEdtSobreNome.Text = EmptyStr) OR
     (lblEdtCep.Text = EmptyStr) OR (lblEdtCpf.Text = EmptyStr)) then
    raise Exception.Create('Erro de Validação, preencha os campos da Pessoa!');

end;

procedure TfmMain.ResetRestApiDefault;
begin
  RESTClient1.ResetToDefaults;
  RESTRequest1.ResetToDefaults;
  RESTResponse1.ResetToDefaults;

  RESTClient1.BaseURL := 'http://localhost:8080/datasnap/rest/TSrvServices';
end;

procedure TfmMain.btnPutClick(Sender: TObject);
begin
 ValidaCampos(TRESTRequestMethod.rmPUT);
 btnPut.Enabled:= false;

 TTask.Run(
    procedure
    Var
      LJson: String;
      objBase: TJSonObject;
      Pessoa: TPessoa;
      Endereco: TEndereco;
    begin
     try
      ResetRestApiDefault;

      Pessoa:= TPessoa.Create;
      Pessoa.idpessoa:= lblEdtCpf.Tag;
      Pessoa.flnatureza:= rgNatureza.ItemIndex;
      Pessoa.dsdocumento:= lblEdtCpf.Text;
      Pessoa.nmprimeiro:= lblEdtNome.Text;
      Pessoa.nmsegundo:= lblEdtSobreNome.Text;

      objBase:= TJson.ObjectToJsonObject(Pessoa);

      //Put Obj Pessoa
      TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
          RESTRequest1.Method := TRESTRequestMethod.rmPUT;
          RESTRequest1.Resource := '/pessoas';
          RESTRequest1.AddBody(objBase.ToString, contentTypeFromString('application/json'));
          RESTRequest1.Execute;

          LJson := StringReplace(RESTResponse1.JSONValue.ToString, '"', '', [rfReplaceAll]);
          if (LJson.Contains('true'))  then
          begin

           //Put Obj Endereco
           Endereco:= TEndereco.Create;
           Endereco.idendereco:= lblEdtCep.Tag;
           Endereco.idpessoa:= lblEdtCpf.Tag;
           Endereco.dscep:= lblEdtCep.Text;
           objBase:= TJson.ObjectToJsonObject(Endereco);

           ResetRestApiDefault;
           RESTRequest1.Method := TRESTRequestMethod.rmPUT;
           RESTRequest1.Resource := '/endereco';
           RESTRequest1.AddBody(objBase.ToString, contentTypeFromString('application/json'));
           RESTRequest1.Execute;

           ShowMessage('Pessoa atualizado com sucesso!');
          end
          else
           ShowMessage('Erro ao tentar atualizar a Pessoa!');
        end);
      finally
       btnPut.Enabled:= true;
       FreeAndNil(Pessoa);
       FreeAndNil(objBase);
      end;
    end);
end;

procedure TfmMain.btnPutEnderecoClick(Sender: TObject);
begin
  //Validações
  if (lblEdtCpf.Tag = 0) then
  begin
    edtFiltro.SetFocus;
    raise Exception.Create('Erro de Validação, Selecione a pessoa primeiro!');
  end;

  if (lblEdtCep.Text = EmptyStr) then
  begin
    lblEdtCep.SetFocus;
    raise Exception.Create('Erro de Validação, Preencha o Cep primeiro!');
  end;

 TTask.Run(
    procedure
    Var
      LJson: String;
      objBase: TJSonObject;
      Endereco: TEndereco;
    begin
     try
      btnPutEndereco.Enabled:= false;
      ResetRestApiDefault;

      //Post/Put Obj Endereco
      TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
            RESTRequest1.Method := TRESTRequestMethod.rmPOST;
            //Insere Endereco
            Endereco:= TEndereco.Create;
            Endereco.idendereco:= 0;
            if (lblEdtCep.Tag > 0) then
            begin
             //Atualiza Endereco
             ResetRestApiDefault;
             RESTRequest1.Method := TRESTRequestMethod.rmPUT;
             Endereco.idendereco:= lblEdtCep.Tag;
            end;

            Endereco.idpessoa:= lblEdtCpf.Tag;
            Endereco.dscep:= lblEdtCep.Text;
            objBase:= TJson.ObjectToJsonObject(Endereco);

            RESTRequest1.Resource := '/endereco';
            RESTRequest1.AddBody(objBase.ToString, contentTypeFromString('application/json'));
            RESTRequest1.Execute;

            LJson := StringReplace(RESTResponse1.JSONValue.ToString, '"', '', [rfReplaceAll]);
            if (LJson.Contains('true'))  then
            begin
             //Mostra mensagem
             ShowMessage('Endereço atualizado com sucesso!');
            end
            else
             ShowMessage('Erro ao tentar atualizar o endereço!');
        end);
      finally
       btnPutEndereco.Enabled:= true;
       FreeAndNil(Endereco);
       FreeAndNil(objBase);
      end;
    end);
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
 edtFiltro.Clear;
 LimparCampos;
end;

procedure TfmMain.lblEdtCpfEnter(Sender: TObject);
begin
 TLabeledEdit(Sender).Color := clAqua;
end;

procedure TfmMain.lblEdtCpfExit(Sender: TObject);
begin
 TLabeledEdit(Sender).Color := clWindow;
end;

procedure TfmMain.btnDeleteClick(Sender: TObject);
begin
  ValidaCampos(TRESTRequestMethod.rmDELETE);
  btnDelete.Enabled:= false;

  TTask.Run(
    procedure
    Var
      LJson: String;
    begin
     try
      ResetRestApiDefault;
      RESTRequest1.Method := TRESTRequestMethod.rmDELETE;

      //Delete Obj Pessoa
      TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
            RESTRequest1.Resource := '/pessoas/' + lblEdtCpf.Tag.ToString;
            RESTRequest1.Execute;

            LJson := RESTResponse1.JSONValue.ToString;
            if (LJson.Contains('true'))  then
            begin
              LimparCampos;
              ShowMessage('Pessoa excluido com sucesso!')
            end
            else
             ShowMessage('Erro ao tentar excluir a Pessoa!');
        end);
      finally
       btnDelete.Enabled:= true;
      end;
    end);
end;

procedure TfmMain.btnGetClick(Sender: TObject);
begin
  ValidaCampos(TRESTRequestMethod.rmGET);
  btnGet.Enabled:= false;
  LimparCampos;

  TTask.Run(
    procedure
    Var
      LJson: String;
      objBase: TJSonObject;
      Pessoa: TPessoa;
      Endereco: TEndereco;
    begin
      try
      ResetRestApiDefault;

      //Get Pessoa por ID
      RESTRequest1.Method := TRESTRequestMethod.rmGET;
      RESTRequest1.Resource := '/pessoas/' + edtFiltro.Text;
      RESTRequest1.Execute;

      LJson := RESTResponse1.JSONValue.ToString;
      objBase := TJSonObject.ParseJSONValue(TEncoding.UTF8.GetBytes
        (LJson), 0) as TJSonObject;
      Pessoa := TJson.JsonToObject<TPessoa>(objBase.ToJSON());

      if (Pessoa.idpessoa = 0)  then
       ShowMessage('Pessoa não localizada!')
      else
      begin
        //Mostra os dados da Pessoa
        TThread.Synchronize(TThread.CurrentThread,
          procedure
          begin
           lblEdtCpf.Tag := Pessoa.idpessoa;
           lblEdtCpf.Text := Pessoa.dsdocumento;
           lblEdtNome.Text := Pessoa.nmprimeiro;
           lblEdtSobreNome.Text := Pessoa.nmsegundo;
           rgNatureza.ItemIndex := Pessoa.flnatureza;
          end);

        //Get Endereco por ID Pessoa
        TThread.Synchronize(TThread.CurrentThread,
          procedure
          begin
            RESTRequest1.Method := TRESTRequestMethod.rmGET;
            RESTRequest1.Resource := '/enderecoByPessoa/' + Pessoa.idpessoa.ToString;
            RESTRequest1.Execute;
            LJson := RESTResponse1.JSONValue.ToString;
            objBase := TJSonObject.ParseJSONValue(TEncoding.UTF8.GetBytes(LJson),
              0) as TJSonObject;
            Endereco := TJson.JsonToObject<TEndereco>(objBase.ToJSON());

            lblEdtCep.Tag := Endereco.idendereco;
            lblEdtCep.Text := Endereco.dscep;
          end);
      end;

      finally
       btnGet.Enabled:= true;
       FreeAndNil(Pessoa);
       FreeAndNil(Endereco);
       FreeAndNil(objBase);
      end;

    end);
end;

procedure TfmMain.btnPostClick(Sender: TObject);
begin
 ValidaCampos(TRESTRequestMethod.rmPOST);
 btnPost.Enabled:= false;

 TTask.Run(
    procedure
    Var
      idPessoa: String;
      objBase: TJSonObject;
      Pessoa: TPessoa;
      Endereco: TEndereco;
    begin
     try
      ResetRestApiDefault;

      Pessoa:= TPessoa.Create;
      Pessoa.idpessoa:= 0;
      Pessoa.dtregistro:= DateToStr(Date);
      Pessoa.flnatureza:= rgNatureza.ItemIndex;
      Pessoa.dsdocumento:= lblEdtCpf.Text;
      Pessoa.nmprimeiro:= lblEdtNome.Text;
      Pessoa.nmsegundo:= lblEdtSobreNome.Text;

      objBase:= TJson.ObjectToJsonObject(Pessoa);

      //Post Obj Pessoa
      TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
            RESTRequest1.Method := TRESTRequestMethod.rmPOST;
            RESTRequest1.Resource := '/pessoas';
            RESTRequest1.AddBody(objBase.ToString, contentTypeFromString('application/json'));
            RESTRequest1.Execute;

            idPessoa := StringReplace(RESTResponse1.JSONValue.ToString, '"', '', [rfReplaceAll]);
            if (StrToIntDef(idPessoa, 0) > 0) then
            begin
             //Post Obj Endereco
             Endereco:= TEndereco.Create;
             Endereco.idendereco:= 0;
             Endereco.idpessoa:= StrToInt(idPessoa); //Id Pessoa
             Endereco.dscep:= lblEdtCep.Text;
             objBase:= TJson.ObjectToJsonObject(Endereco);

             ResetRestApiDefault;
             RESTRequest1.Method := TRESTRequestMethod.rmPOST;
             RESTRequest1.Resource := '/endereco';
             RESTRequest1.AddBody(objBase.ToString, contentTypeFromString('application/json'));
             RESTRequest1.Execute;

             //Mostra mensagem
             ShowMessage('Pessoa inserida com sucesso!');
            end
            else
             ShowMessage('Erro ao tentar inserir a Pessoa!');
        end);
      finally
       btnPost.Enabled:= true;
       if (Assigned(Endereco)) then
        FreeAndNil(Endereco);

       FreeAndNil(Pessoa);
       FreeAndNil(objBase);
      end;
    end);

end;

procedure TfmMain.btnAbrirTXTClick(Sender: TObject);
Var
  arqFileTxt: TextFile;
  linhaTxt, cepTxt: String;
  Cont, idpessoa, PosBarra: Integer;
begin
  OpenFile.FileName := '';
  OpenFile.Title := 'Selecione a TXT';
  OpenFile.DefaultExt := '*.TXT';
  OpenFile.Filter := 'Arquivos TXT (*.TXT)';
  OpenFile.InitialDir := 'C:\';
  if OpenFile.Execute then
  begin
    Cont:=0;
    btnAbrirTXT.Enabled:= false;

    cdsArquivoTXT.EmptyDataSet;
    cdsArquivoTXT.First;
    cdsArquivoTXT.DisableControls;

    AssignFile(arqFileTxt, OpenFile.FileName);
    Reset(arqFileTxt);
    while not Eof(arqFileTxt) do
    begin

      TThread.Synchronize(nil,
        procedure
        begin

          ReadLn(arqFileTxt, linhaTxt);
          // formato do TXT: 1|1234|NEUZA FARIA|OLIVEIRA|09431300
          cdsArquivoTXT.Append;

          Inc(Cont);
          cdsArquivoTXTid.AsInteger := Cont;

          // Preenche OBJ Pessoa
          PosBarra := Pos('|', linhaTxt);
          cdsArquivoTXTdsnatureza.AsInteger :=
            StrToInt(Copy(linhaTxt, 1, PosBarra - 1));
          Delete(linhaTxt, 1, PosBarra);

          PosBarra := Pos('|', linhaTxt);
          cdsArquivoTXTdsdocumento.AsString := Copy(linhaTxt, 1, PosBarra - 1);
          Delete(linhaTxt, 1, PosBarra);

          PosBarra := Pos('|', linhaTxt);
          cdsArquivoTXTnmprimeiro.AsString := Copy(linhaTxt, 1, PosBarra - 1);
          Delete(linhaTxt, 1, PosBarra);

          PosBarra := Pos('|', linhaTxt);
          cdsArquivoTXTnmsegundo.AsString := Copy(linhaTxt, 1, PosBarra - 1);
          Delete(linhaTxt, 1, PosBarra);

          cepTxt := linhaTxt;
          cdsArquivoTXTdscep.AsString := cepTxt;

        end);

    end;

    CloseFile(arqFileTxt);
    cdsArquivoTXT.First;
    cdsArquivoTXT.EnableControls;
    btnAbrirTXT.Enabled:= true;
    ShowMessage('Arquivo importado com sucesso!');

  end;
end;

procedure TfmMain.btnImportarClick(Sender: TObject);

begin
 if cdsArquivoTXT.IsEmpty then
  raise Exception.Create('Selecionar o arquivo de importação!');

 btnImportar.Enabled:= false;

 TTask.Run(procedure
  Var
   LJson: String;

   StrAux: TStringWriter;
   TxtJSON: TJSONTextWriter;
   ljObj: TJSonObject;
   ljArray: TJSONArray;

   StreamIn: TStream;
   StreamOut: TStringStream;

  begin
   try
    ResetRestApiDefault;

    RESTRequest1.Resource:= '/importar';
    RESTRequest1.Method:= TRESTRequestMethod.rmPOST;

    ljArray := TJSONArray.Create;
    StrAux := TStringWriter.Create;
    TxtJSON := TJSONTextWriter.Create(StrAux);
    StreamIn := TMemoryStream.Create;
    StreamOut := TStringStream.Create;

    StreamIn.Position := 0;
    StreamOut.Position := 0;

    TxtJSON.Formatting := TJsonFormatting.Indented;

    //Pega arquivo e coloca num stream
    TThread.Synchronize(nil,
      procedure
      begin
        StreamIn := TFileStream.Create(OpenFile.FileName, fmOpenRead);
      end);

    StreamIn.Position := 0;
    TNetEncoding.Base64.Encode(StreamIn, StreamOut);
    StreamOut.Position := 0;

    //Cabeçalho
    TxtJSON.WriteStartObject; // Objeto Global
    TxtJSON.WritePropertyName('lote');
    TxtJSON.WriteStartArray; // Array Pedido

    TxtJSON.WriteStartObject;

    TxtJSON.WritePropertyName('file');
    TxtJSON.WriteValue(StreamOut.DataString);

    //Finaliza Json
    TxtJSON.WriteEndArray; // Array Perfil
    TxtJSON.WriteEndObject; // Objeto Global

    ljObj := TJSonObject.ParseJSONValue
      (TEncoding.ASCII.GetBytes(StrAux.toString), 0) as TJSonObject;

    ljArray.AddElement(ljObj);

    TThread.Synchronize(TThread.CurrentThread,
    procedure
    begin
       RESTRequest1.Method := TRESTRequestMethod.rmPOST;
       RESTRequest1.AddBody(ljArray.ToString, contentTypeFromString('application/json'));
       RESTRequest1.Execute;
       LJson:= RESTResponse1.JSONValue.ToString;

       if (LJson.Contains('true'))  then
       begin
        ShowMessage('Arquivo importado!');
        cdsArquivoTXT.EmptyDataSet;
       end
       else
        ShowMessage('Erro ao tentar inserir a Pessoa!');
    end);

   finally
    btnImportar.Enabled:= true;
    FreeAndNil(StreamIn);
    FreeAndNil(StreamOut);
    FreeAndNil(TxtJSON);
    FreeAndNil(ljArray);
   end;

  end);

end;

procedure TfmMain.LimparCampos;
begin
 lblEdtCpf.Tag:= 0;
 lblEdtCpf.Clear;
 lblEdtNome.Clear;
 lblEdtSobreNome.Clear;
 lblEdtCep.Tag:= 0;
 lblEdtCep.Clear;
end;

end.
