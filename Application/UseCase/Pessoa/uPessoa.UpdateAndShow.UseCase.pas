unit uPessoa.UpdateAndShow.UseCase;

interface

uses
  uPessoa.UpdateAndShow.UseCase.Interfaces,
  uPessoa.Repository.Interfaces,
  uPessoa.Update.DTO,
  uPessoa.Show.DTO;

type
  TPessoaUpdateAndShowUseCase = class(TInterfacedObject, IPessoaUpdateAndShowUseCase)
  private
    FRepository: IPessoaRepository;
    constructor Create(ARepository: IPessoaRepository);
  public
    class function Make(ARepository: IPessoaRepository): IPessoaUpdateAndShowUseCase;
    function Execute(AId: Int64; AInput: TPessoaUpdateDTO): TPessoaShowDTO;
  end;

implementation

uses
  uPessoa,
  uPessoa.Mapper,
  System.SysUtils,
  uSmartPointer;

{ TPessoaUpdateAndShowUseCase }

constructor TPessoaUpdateAndShowUseCase.Create(ARepository: IPessoaRepository);
begin
  inherited Create;
  FRepository := ARepository;
end;

function TPessoaUpdateAndShowUseCase.Execute(AId: Int64; AInput: TPessoaUpdateDTO): TPessoaShowDTO;
const
  LMSG = 'Pessoa não foi encontrada com o id: %s';
var
  lEntityToUpdate: Shared<TPessoa>;
  lEntityFound: Shared<TPessoa>;
begin
  Result := Nil;

  // Mapear dados para entidade
  lEntityToUpdate := TPessoaMapper.DtoToEntity(AInput);

  // Validar dados
  With lEntityToUpdate.Value do
  begin
    idpessoa := AId;
    BeforeSaveAndValidate;
  end;

  // Atualizar
  FRepository.Update(AId, lEntityToUpdate);

  // Localizar registro atualizado
  lEntityFound := FRepository.Show(AId);
  if not Assigned(lEntityFound.Value) then
    raise Exception.Create(Format(LMSG, [AId.ToString]));

  // Retornar DTO
  Result := TPessoaMapper.EntityToShowDTO(lEntityFound);
end;

class function TPessoaUpdateAndShowUseCase.Make(ARepository: IPessoaRepository): IPessoaUpdateAndShowUseCase;
begin
  Result := Self.Create(ARepository);
end;

end.
