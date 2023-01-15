unit uPessoa;

interface

uses
  uBase.Entity,
  uPessoa.FlNatureza.Types,
  uCpfCnpj.ValueObject,
  uEndereco;

type
  TPessoa = class(TBaseEntity)
  private
    Fnmprimeiro: String;
    Fdtregistro: TDateTime;
    Fnmsegundo: String;
    Fdsdocumento: TCpfCnpjValueObject;
    Fidpessoa: Int64;
    Fflnatureza: TPessoaFlNaturezaType;

    // OneToOne
    FEndereco: TEndereco;

    procedure Setdsdocumento(const Value: TCpfCnpjValueObject);
    function Getendereco: TEndereco;
  public
    constructor Create;
    destructor Destroy; override;

    property idpessoa: Int64 read Fidpessoa write Fidpessoa;
    property flnatureza: TPessoaFlNaturezaType read Fflnatureza write Fflnatureza;
    property dsdocumento: TCpfCnpjValueObject read Fdsdocumento write Setdsdocumento;
    property nmprimeiro: String read Fnmprimeiro write Fnmprimeiro;
    property nmsegundo: String read Fnmsegundo write Fnmsegundo;
    property dtregistro: TDateTime read Fdtregistro write Fdtregistro;

    // OneToOne
    property endereco: TEndereco read Getendereco write Fendereco;

    procedure Validate; override;
    procedure BeforeSaveAndValidate;
  end;

implementation

uses
  System.SysUtils,
  uEntityValidation.Exception,
  uHlp;

{ TPessoa }

procedure TPessoa.BeforeSaveAndValidate;
begin
  case Fdsdocumento.IsCpf of
    True:  Fflnatureza := TPessoaFlNaturezaType.Fisica;
    False: Fflnatureza := TPessoaFlNaturezaType.Juridica;
  end;
  FEndereco.dscep := THlp.OnlyNumbers(FEndereco.dscep);

  Validate;
end;

constructor TPessoa.Create;
begin
  inherited Create;
  Fdsdocumento := TCpfCnpjValueObject.Make(EmptyStr);
  FEndereco    := TEndereco.Create;
end;

destructor TPessoa.Destroy;
begin
  if Assigned(Fdsdocumento) then FreeAndNil(Fdsdocumento);
  if Assigned(FEndereco)    then FreeAndNil(FEndereco);
  inherited;
end;

function TPessoa.Getendereco: TEndereco;
begin
  if not Assigned(FEndereco) then
    FEndereco := TEndereco.Create;
  Result := Fendereco;
end;

procedure TPessoa.Setdsdocumento(const Value: TCpfCnpjValueObject);
begin
  if Assigned(Fdsdocumento) then FreeAndNil(Fdsdocumento);
  Fdsdocumento := Value;
end;

procedure TPessoa.Validate;
begin
  inherited;
  if Fdsdocumento.Value.Trim.IsEmpty then
    raise TEntityValidationException.Create('O campo [CPF/CNPJ] é obrigatório.');

  if Fnmprimeiro.Trim.IsEmpty then
    raise TEntityValidationException.Create('O campo [Primeiro Nome] é obrigatório.');

  if Fnmsegundo.Trim.IsEmpty then
    raise TEntityValidationException.Create('O campo [Sobrenome] é obrigatório.');

  FEndereco.Validate;
end;

end.
