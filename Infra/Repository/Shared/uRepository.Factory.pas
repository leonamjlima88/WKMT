unit uRepository.Factory;

interface

uses
  uPessoa.Repository.Interfaces,
  uTarefa.Repository.Interfaces,
  uRepository.Factory.Interfaces,
  uZLConnection.Interfaces;

type
  TRepositoryFactory = class(TInterfacedObject, IRepositoryFactory)
  private
    FConn: IZLConnection;
    constructor Create(AConn: IZLConnection);
  public
    class function Make(AConn: IZLConnection = nil): IRepositoryFactory;
    function Pessoa: IPessoaRepository;
    function Tarefa: ITarefaRepository;
  end;

implementation

{ TRepositoryFactory }

uses
  uPessoa.Repository,
  uTarefa.Repository,
  uConnection.Factory;

constructor TRepositoryFactory.Create(AConn: IZLConnection);
begin
  inherited Create;
  FConn := AConn;

  if not Assigned(FConn) then
    FConn := TConnectionFactory.Make;
end;

class function TRepositoryFactory.Make(AConn: IZLConnection): IRepositoryFactory;
begin
  Result := Self.Create(AConn);
end;

function TRepositoryFactory.Pessoa: IPessoaRepository;
begin
  Result := TPessoaRepository.Make(FConn);
end;

function TRepositoryFactory.Tarefa: ITarefaRepository;
begin
  Result := TTarefaRepository.Make(FConn);
end;

end.
