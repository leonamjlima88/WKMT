unit uEnderecoIntegracao;

interface

uses
  uBase.Entity;

type
  TEnderecoIntegracao = class(TBaseEntity)
  private
    Fnmcidade: String;
    Fnmlogradouro: String;
    Fidendereco: Int64;
    Fnmbairro: String;
    Fdsuf: String;
    Fdscomplemento: String;
  public
    constructor Create;
    destructor Destroy; override;

    property idendereco: Int64 read Fidendereco write Fidendereco;
    property dsuf: String read Fdsuf write Fdsuf;
    property nmcidade: String read Fnmcidade write Fnmcidade;
    property nmbairro: String read Fnmbairro write Fnmbairro;
    property nmlogradouro: String read Fnmlogradouro write Fnmlogradouro;
    property dscomplemento: String read Fdscomplemento write Fdscomplemento;

    procedure Validate; override;
  end;

implementation

{ TPessoa }

constructor TEnderecoIntegracao.Create;
begin
  inherited Create;
end;

destructor TEnderecoIntegracao.Destroy;
begin
  inherited;
end;

procedure TEnderecoIntegracao.Validate;
begin
  inherited;
//
end;

end.
