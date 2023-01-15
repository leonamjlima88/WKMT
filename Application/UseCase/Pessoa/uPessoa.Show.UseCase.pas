unit uPessoa.Show.UseCase;

interface

uses
  uPessoa.Show.UseCase.Interfaces,
  uPessoa.Repository.Interfaces,
  uPessoa.Show.DTO;

type
  TPessoaShowUseCase = class(TInterfacedObject, IPessoaShowUseCase)
  private
    FRepository: IPessoaRepository;
    constructor Create(ARepository: IPessoaRepository);
  public
    class function Make(ARepository: IPessoaRepository): IPessoaShowUseCase;
    function Execute(AId: Int64): TPessoaShowDTO;
  end;

implementation

uses
  System.SysUtils,
  uPessoa,
  uPessoa.Mapper,
  uSmartPointer;

{ TPessoaShowUseCase }

constructor TPessoaShowUseCase.Create(ARepository: IPessoaRepository);
begin
  inherited Create;
  FRepository := ARepository;
end;

function TPessoaShowUseCase.Execute(AId: Int64): TPessoaShowDTO;
var
  lEntity: Shared<TPessoa>;
begin
  Result := Nil;

  // Localizar Registro
  lEntity := FRepository.Show(AId);
  if not Assigned(lEntity.Value) then
    Exit;

  // Retornar DTO
  Result := TPessoaMapper.EntityToShowDTO(lEntity);
end;

class function TPessoaShowUseCase.Make(ARepository: IPessoaRepository): IPessoaShowUseCase;
begin
  Result := Self.Create(ARepository);
end;

end.
