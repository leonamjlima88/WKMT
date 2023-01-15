unit uPessoa.Mapper;

interface

uses
  uBase.DTO,
  uPessoa,
  uPessoa.Show.DTO;

type
  TPessoaMapper = class
  private
  public
    class function DtoToEntity(AInput: TBaseDTO): TPessoa;
    class function EntityToShowDTO(AEntity: TPessoa): TPessoaShowDTO;
  end;

implementation

{ TPessoaMapper }

uses
  REST.Json,
  System.JSON,
  System.SysUtils,
  uCpfCnpj.ValueObject,
  uPessoa.Store.DTO,
  uHlp;

class function TPessoaMapper.EntityToShowDTO(AEntity: TPessoa): TPessoaShowDTO;
var
  lJsonString: String;
begin
  lJsonString := TJson.ObjectToJsonString(AEntity);
  Result      := TJson.JsonToObject<TPessoaShowDTO>(lJsonString);

  // Tratar especificidades
  Result.dsdocumento_value   := AEntity.dsdocumento.Value;
  Result.endereco_idendereco := AEntity.endereco.idendereco;
  Result.endereco_dscep      := AEntity.endereco.dscep;
end;

class function TPessoaMapper.DtoToEntity(AInput: TBaseDTO): TPessoa;
var
  lJsonString: String;
begin
  lJsonString := TJson.ObjectToJsonString(AInput);
  Result      := TJson.JsonToObject<TPessoa>(lJsonString);

  // Tratar especificidades
  if (AInput is TPessoaStoreDTO) then
  Begin
    Result.dsdocumento    := TCpfCnpjValueObject.Make((AInput as TPessoaStoreDTO).dsdocumento_value);
    Result.endereco.dscep := (AInput as TPessoaStoreDTO).endereco_dscep;
  end;
end;

end.
