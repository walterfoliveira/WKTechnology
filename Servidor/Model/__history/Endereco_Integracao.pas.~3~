unit Endereco_Integracao;

interface

type
 TEndereco_Integracao = Class
  private
    Fnmcidade: string;
    Fnmlogradouro: string;
    Fidendereco: Integer;
    Fnmbairro: string;
    Fdsuf: string;
    Fnmcomplemento: string;
    procedure Setdsuf(const Value: string);
    procedure Setidendereco(const Value: Integer);
    procedure Setnmbairro(const Value: string);
    procedure Setnmcidade(const Value: string);
    procedure Setnmcomplemento(const Value: string);
    procedure Setnmlogradouro(const Value: string);
  public
   property idendereco: Integer read Fidendereco write Setidendereco;
   property dsuf: string read Fdsuf write Setdsuf;
   property nmcidade: string read Fnmcidade write Setnmcidade;
   property nmbairro: string read Fnmbairro write Setnmbairro;
   property nmlogradouro: string read Fnmlogradouro write Setnmlogradouro;
   property nmcomplemento: string read Fnmcomplemento write Setnmcomplemento;

 End;

implementation

{ TEndereco_Integracao }

procedure TEndereco_Integracao.Setdsuf(const Value: string);
begin
  Fdsuf := Value;
end;

procedure TEndereco_Integracao.Setidendereco(const Value: Integer);
begin
  Fidendereco := Value;
end;

procedure TEndereco_Integracao.Setnmbairro(const Value: string);
begin
  Fnmbairro := Value;
end;

procedure TEndereco_Integracao.Setnmcidade(const Value: string);
begin
  Fnmcidade := Value;
end;

procedure TEndereco_Integracao.Setnmcomplemento(const Value: string);
begin
  Fnmcomplemento := Value;
end;

procedure TEndereco_Integracao.Setnmlogradouro(const Value: string);
begin
  Fnmlogradouro := Value;
end;

end.

