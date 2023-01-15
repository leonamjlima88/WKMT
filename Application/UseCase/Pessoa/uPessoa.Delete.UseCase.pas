unit uPessoa.Delete.UseCase;

interface

uses
  uPessoa.Delete.UseCase.Interfaces,
  uPessoa.Repository.Interfaces;

type
  TPessoaDeleteUseCase = class(TInterfacedObject, IPessoaDeleteUseCase)
  private
    FRepository: IPessoaRepository;
    constructor Create(ARepository: IPessoaRepository);
  public
    class function Make(ARepository: IPessoaRepository): IPessoaDeleteUseCase;
    function Execute(AId: Int64): Boolean;
  end;

implementation

{ TPessoaDeleteUseCase }

constructor TPessoaDeleteUseCase.Create(ARepository: IPessoaRepository);
begin
  inherited Create;
  FRepository := ARepository;
end;

function TPessoaDeleteUseCase.Execute(AId: Int64): Boolean;
begin
  FRepository.Delete(AId);
  Result := True;
end;

class function TPessoaDeleteUseCase.Make(ARepository: IPessoaRepository): IPessoaDeleteUseCase;
begin
  Result := Self.Create(ARepository);
end;

end.
