unit uPessoa.Index.UseCase;

interface

uses
  uPessoa.Index.UseCase.Interfaces,
  uPessoa.Repository.Interfaces,
  uPessoa.Show.DTO,
  System.Generics.Collections;

type
  TPessoaIndexUseCase = class(TInterfacedObject, IPessoaIndexUseCase)
  private
    FRepository: IPessoaRepository;
    constructor Create(ARepository: IPessoaRepository);
  public
    class function Make(ARepository: IPessoaRepository): IPessoaIndexUseCase;
    function Execute: TObjectList<TPessoaShowDTO>;
  end;

implementation

{ TPessoaIndexUseCase }

uses
  System.SysUtils,
  uPessoa,
  uPessoa.Mapper,
  REST.Json,
  uSmartPointer;

constructor TPessoaIndexUseCase.Create(ARepository: IPessoaRepository);
begin
  inherited Create;
  FRepository := ARepository;
end;

function TPessoaIndexUseCase.Execute: TObjectList<TPessoaShowDTO>;
var
  lEntityList: Shared<TObjectList<TPessoa>>;
  lEntity: TPessoa;
begin
  Result := TObjectList<TPessoaShowDTO>.Create;

  // Localizar dados
  lEntityList := FRepository.Index;

  // Retornar DTO
  for lEntity in lEntityList.Value do
    Result.Add(TPessoaMapper.EntityToShowDTO(lEntity));
end;

class function TPessoaIndexUseCase.Make(ARepository: IPessoaRepository): IPessoaIndexUseCase;
begin
  Result := Self.Create(ARepository);
end;

end.
