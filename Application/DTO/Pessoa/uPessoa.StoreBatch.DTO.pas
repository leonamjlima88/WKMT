unit uPessoa.StoreBatch.DTO;

interface

uses
  uBase.DTO,
  uPessoa.Store.DTO,
  System.Generics.Collections;

type
  TPessoaStoreBatchDTO = class(TBaseDTO)
  private
    Fbatch: TObjectList<TPessoaStoreDTO>;
    Fidentificacao: string;
  public
    constructor Create;
    destructor Destroy; override;
    property identificacao: string read Fidentificacao write Fidentificacao;
    property batch: TObjectList<TPessoaStoreDTO> read Fbatch write Fbatch;

    class function FromJsonString(AIdentification: String; AJsonString: String): TPessoaStoreBatchDTO;
  end;

implementation

uses
  REST.Json,
  System.JSON,
  System.SysUtils,
  uSmartPointer;

{ TPessoaStoreBatchDTO }

constructor TPessoaStoreBatchDTO.Create;
begin
  inherited Create;
  Fbatch := TObjectList<TPessoaStoreDTO>.Create;
end;

destructor TPessoaStoreBatchDTO.Destroy;
begin
  if Assigned(Fbatch) then Fbatch.Free;

  inherited;
end;

class function TPessoaStoreBatchDTO.FromJsonString(AIdentification: String; AJsonString: String): TPessoaStoreBatchDTO;
var
  lJsonObj: Shared<TJSONObject>;
  lJsonArray: TJSONArray;
  lI: Integer;
begin
  Result := Self.Create;

  lJsonObj   := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(AJsonString), 0) as TJSONObject;
  lJsonArray := lJsonObj.Value.Get('batch').JsonValue as TJSONArray;

  Result.identificacao := AIdentification;
  for lI := 0 to Pred(lJsonArray.Size) do
    Result.Fbatch.Add(TJson.JsonToObject<TPessoaStoreDTO>(lJsonArray.Get(lI) as TJSONObject));
end;

end.
