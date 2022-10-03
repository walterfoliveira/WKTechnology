unit Endereco;

interface

type
  TEndereco = class
  private
    Fidendereco: Integer;
    Fdscep: string;
    Fidpessoa: Integer;
    procedure Setdscep(const Value: string);
    procedure Setidendereco(const Value: Integer);
    procedure Setidpessoa(const Value: Integer);
  public
    property idendereco: Integer read Fidendereco write Setidendereco;
    property idpessoa: Integer read Fidpessoa write Setidpessoa;
    property dscep: string read Fdscep write Setdscep;
  end;

implementation



{ TEndereco }

procedure TEndereco.Setdscep(const Value: string);
begin
  Fdscep := Value;
end;

procedure TEndereco.Setidendereco(const Value: Integer);
begin
  Fidendereco := Value;
end;

procedure TEndereco.Setidpessoa(const Value: Integer);
begin
  Fidpessoa := Value;
end;

end.


