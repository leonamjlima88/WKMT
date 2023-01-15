unit uEndereco;

interface

uses
  uBase.Entity;

type
  TEndereco = class(TBaseEntity)
  private
    Fidendereco: Int64;
    Fdscep: String;
    Fidpessoa: Int64;
  public
    constructor Create;
    destructor Destroy; override;

    property idendereco: Int64 read Fidendereco write Fidendereco;
    property idpessoa: Int64 read Fidpessoa write Fidpessoa;
    property dscep: String read Fdscep write Fdscep;

    procedure Validate; override;
  end;

implementation

uses
  System.SysUtils,
  uEntityValidation.Exception,
  uHlp;

{ TEndereco }

const
  DSCEP_LENGTH = 8;

constructor TEndereco.Create;
begin
  inherited Create;
end;

destructor TEndereco.Destroy;
begin
  inherited;
end;

procedure TEndereco.Validate;
begin
  inherited;

  if Fdscep.Trim.IsEmpty then
    raise TEntityValidationException.Create('O campo [CEP] é obrigatório.');

  if THlp.OnlyNumbers(Fdscep).Trim.Length <> DSCEP_LENGTH then
    raise TEntityValidationException.Create(Format('O campo [CEP] deve conter [%s] caracteres.', [DSCEP_LENGTH.ToString]));
end;

end.
