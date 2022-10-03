unit Pessoa;

interface

type
 TPessoa = class
  private
    Fnmprimeiro: String;
    Fdtregistro: String;
    Fnmsegundo: String;
    Fdsdocumento: String;
    Fidpessoa: Integer;
    Fflnatureza: Integer;

    procedure Setdsdocumento(const Value: String);
    procedure Setdtregistro(const Value: String);
    procedure Setflnatureza(const Value: Integer);
    procedure Setidpessoa(const Value: Integer);
    procedure Setnmprimeiro(const Value: String);
    procedure Setnmsegundo(const Value: String);

    public
     property idpessoa: Integer read Fidpessoa write Setidpessoa;
     property flnatureza: Integer read Fflnatureza write Setflnatureza;
     property dsdocumento: String read Fdsdocumento write Setdsdocumento;
     property nmprimeiro: String read Fnmprimeiro write Setnmprimeiro;
     property nmsegundo: String read Fnmsegundo write Setnmsegundo;
     property dtregistro: String read Fdtregistro write Setdtregistro;

 end;

implementation

{ TPessoa }

procedure TPessoa.Setdsdocumento(const Value: String);
begin
  Fdsdocumento := Value;
end;

procedure TPessoa.Setdtregistro(const Value: String);
begin
  Fdtregistro := Value;
end;

procedure TPessoa.Setflnatureza(const Value: Integer);
begin
  Fflnatureza := Value;
end;

procedure TPessoa.Setidpessoa(const Value: Integer);
begin
  Fidpessoa := Value;
end;

procedure TPessoa.Setnmprimeiro(const Value: String);
begin
  Fnmprimeiro := Value;
end;

procedure TPessoa.Setnmsegundo(const Value: String);
begin
  Fnmsegundo := Value;
end;

end.

