unit uPessoa.StoreAndShow.UseCase;

interface

uses
  uPessoa.StoreAndShow.UseCase.Interfaces,
  uPessoa.Repository.Interfaces,
  uPessoa.Store.DTO,
  uPessoa.Show.DTO;

type
  TPessoaStoreAndShowUseCase = class(TInterfacedObject, IPessoaStoreAndShowUseCase)
  private
    FRepository: IPessoaRepository;
    constructor Create(ARepository: IPessoaRepository);
  public
    class function Make(ARepository: IPessoaRepository): IPessoaStoreAndShowUseCase;
    function Execute(AInput: TPessoaStoreDTO): TPessoaShowDTO;
  end;

implementation

uses
  uPessoa,
  uPessoa.Mapper,
  uSmartPointer;

{ TPessoaStoreAndShowUseCase }

constructor TPessoaStoreAndShowUseCase.Create(ARepository: IPessoaRepository);
begin
  inherited Create;
  FRepository := ARepository;
end;

function TPessoaStoreAndShowUseCase.Execute(AInput: TPessoaStoreDTO): TPessoaShowDTO;
var
  lEntityToStore: Shared<TPessoa>;
  lEntityFound: Shared<TPessoa>;
  lStoredId: Int64;
begin
  Result := Nil;

  // Mapear dados para entidade
  lEntityToStore := TPessoaMapper.DtoToEntity(AInput);

  // Validar dados
  lEntityToStore.Value.BeforeSaveAndValidate;

  // Incluir
  lStoredId := FRepository.Store(lEntityToStore);

  // Localizar registro incluso
  lEntityFound := FRepository.Show(lStoredId);

  // Retornar DTO
  Result := TPessoaMapper.EntityToShowDTO(lEntityFound);
end;

class function TPessoaStoreAndShowUseCase.Make(ARepository: IPessoaRepository): IPessoaStoreAndShowUseCase;
begin
  Result := Self.Create(ARepository);
end;

end.
