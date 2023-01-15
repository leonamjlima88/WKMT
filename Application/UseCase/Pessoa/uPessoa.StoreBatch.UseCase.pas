unit uPessoa.StoreBatch.UseCase;

interface

uses
  uPessoa.StoreBatch.UseCase.Interfaces,
  uPessoa.Repository.Interfaces,
  uTarefa.Repository.Interfaces,
  uPessoa.StoreBatch.DTO,
  uTarefa,
  System.SysUtils;

type
  TPessoaStoreBatchUseCase = class(TInterfacedObject, IPessoaStoreBatchUseCase)
  private
    FRepository: IPessoaRepository;
    FRepositoryTarefa: ITarefaRepository;
    FTarefa: TTarefa;
    FInput: TPessoaStoreBatchDTO;
    constructor Create(ARepository: IPessoaRepository; ARepositoryTarefa: ITarefaRepository);
    destructor Destroy; override;
    function RegisterTaskStart: IPessoaStoreBatchUseCase;
    function RegisterTaskEnd: IPessoaStoreBatchUseCase;
    function RegisterTaskFail(E: Exception): IPessoaStoreBatchUseCase;
    function PerformTask: IPessoaStoreBatchUseCase;
  public
    class function Make(ARepository: IPessoaRepository; ARepositoryTarefa: ITarefaRepository): IPessoaStoreBatchUseCase;
    function Execute(AInput: TPessoaStoreBatchDTO): IPessoaStoreBatchUseCase;
  end;

implementation

uses
  uPessoa.Store.DTO,
  uPessoa.Mapper,
  uPessoa,
  uSmartPointer,
  uTarefa.Status.Types;

{ TPessoaStoreBatchUseCase }

constructor TPessoaStoreBatchUseCase.Create(ARepository: IPessoaRepository; ARepositoryTarefa: ITarefaRepository);
begin
  inherited Create;
  FRepository       := ARepository;
  FRepositoryTarefa := ARepositoryTarefa;
  FRepository.ManageTransaction(False);
  FTarefa := TTarefa.Create;
end;

destructor TPessoaStoreBatchUseCase.Destroy;
begin
  if Assigned(FTarefa) then FTarefa.Free;

  inherited;
end;

function TPessoaStoreBatchUseCase.Execute(AInput: TPessoaStoreBatchDTO): IPessoaStoreBatchUseCase;
begin
  Result := Self;
  FInput := AInput;

  RegisterTaskStart;
  PerformTask;
  RegisterTaskEnd;
end;

class function TPessoaStoreBatchUseCase.Make(ARepository: IPessoaRepository; ARepositoryTarefa: ITarefaRepository): IPessoaStoreBatchUseCase;
begin
  Result := Self.Create(ARepository, ARepositoryTarefa);
end;

function TPessoaStoreBatchUseCase.PerformTask: IPessoaStoreBatchUseCase;
var
  lItem: TPessoaStoreDTO;
  lEntityToStore: Shared<TPessoa>;
begin
  Try
    FRepository.Conn.StartTransaction;

    for lItem in FInput.batch do
    begin
      lEntityToStore := TPessoaMapper.DtoToEntity(lItem);
      lEntityToStore.Value.BeforeSaveAndValidate;
      FRepository.Store(lEntityToStore);
    end;

    FRepository.Conn.CommitTransaction;
  except on E: Exception do
    Begin
      FRepository.Conn.RollBackTransaction;
      RegisterTaskFail(E);
      raise;
    end;
  end;
end;

function TPessoaStoreBatchUseCase.RegisterTaskEnd: IPessoaStoreBatchUseCase;
begin
  Result := Self;

  With FTarefa do
  begin
    mensagem := 'Processo realizado com sucesso.';
    dtfim    := Now;
    status   := TTarefaStatusType.Concluido;
  end;
  FRepositoryTarefa.Update(FTarefa.idtarefa, FTarefa);
end;

function TPessoaStoreBatchUseCase.RegisterTaskFail(E: Exception): IPessoaStoreBatchUseCase;
begin
  // Registrar erro se ocorrer
  With FTarefa do
  begin
    mensagem := 'Ocorreu uma falha: ' + E.Message + '!';
    dtfim    := Now;
    status   := TTarefaStatusType.Falhou;
  end;
  FRepositoryTarefa.Update(FTarefa.idtarefa, FTarefa);
end;

function TPessoaStoreBatchUseCase.RegisterTaskStart: IPessoaStoreBatchUseCase;
begin
  Result := Self;

  With FTarefa do
  begin
    identificacao := FInput.identificacao;
    mensagem      := 'Processando em segundo plano...';
    dtinicio      := Now;
    status        := TTarefaStatusType.Processando;
  end;
  FTarefa.idtarefa := FRepositoryTarefa.Store(FTarefa);
end;

end.
