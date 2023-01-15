unit uTarefa.Repository;

interface

uses
  uTarefa.Repository.Interfaces,
  uTarefa,
  uZLConnection.Interfaces,
  System.Generics.Collections,
  Data.DB;

type
  TTarefaRepository = class(TInterfacedObject, ITarefaRepository)
  private
    FConn: IZLConnection;
    FManageTransaction: Boolean;
    constructor Create(AConn: IZLConnection);
    function DataSetToEntity(ADts: TDataSet; AEntity: TTarefa): ITarefaRepository;
  public
    class function Make(AConn: IZLConnection): ITarefaRepository;
    function Show(AId: Int64): TTarefa;
    function Store(AEntity: TTarefa): Int64;
    function Update(AId: Int64; AEntity: TTarefa): Boolean;
    function Delete(AId: Int64): Boolean;
    function Index: TObjectList<TTarefa>;
    function ExistsStatusLikeProcessOrFinished(AIdentification: String): Boolean;

    function ManageTransaction(AValue: Boolean): ITarefaRepository; overload;
    function ManageTransaction: Boolean; overload;
    function Conn: IZLConnection;
  end;

implementation

uses
  uZLQry.Interfaces,
  System.SysUtils,
  uTarefa.Status.Types;

const
  // TAREFA
  TAREFA_SELECT_ALL = ' SELECT tarefa.* FROM tarefa ';

  TAREFA_SELECT_ALL_WHERE_PK_EQUAL = TAREFA_SELECT_ALL + ' WHERE tarefa.idtarefa = %s';

  TAREFA_INSERT = ' INSERT INTO tarefa                                   '+
                  '   (identificacao, status, mensagem, dtinicio, dtfim) '+
                  ' VALUES(%s, %s, %s, %s, %s) RETURNING idtarefa        ';

  TAREFA_UPDATE = ' UPDATE tarefa                                                       '+
                  ' SET identificacao=%s, status=%s, mensagem=%s, dtinicio=%s, dtfim=%s '+
                  ' WHERE idtarefa=%s                                                   ';

  TAREFA_DELETE_WHERE_PK_EQUAL = ' DELETE FROM tarefa WHERE tarefa.idtarefa = %s ';

{ TTarefaRepository }

function TTarefaRepository.Conn: IZLConnection;
begin
  Result := FConn;
end;

constructor TTarefaRepository.Create(AConn: IZLConnection);
begin
  inherited Create;
  FConn := AConn;
  FManageTransaction := True;
end;

function TTarefaRepository.DataSetToEntity(ADts: TDataSet; AEntity: TTarefa): ITarefaRepository;
begin
  Result := Self;

  With AEntity do
  begin
    // Tarefa
    idtarefa      := ADts.FieldByName('idtarefa').AsLargeInt;
    identificacao := ADts.FieldByName('identificacao').AsString;
    status        := TTarefaStatusType(ADts.FieldByName('status').AsInteger);
    mensagem      := ADts.FieldByName('mensagem').AsString;
    dtinicio      := ADts.FieldByName('dtinicio').AsDateTime;
    dtfim         := ADts.FieldByName('dtfim').AsDateTime;
  end;
end;

function TTarefaRepository.Delete(AId: Int64): Boolean;
begin
  FConn.MakeQry.ExecSQL(
    Format(TAREFA_DELETE_WHERE_PK_EQUAL, [
      QuotedStr(AId.ToString)
    ])
  );
  Result := True;
end;

function TTarefaRepository.ExistsStatusLikeProcessOrFinished(AIdentification: String): Boolean;
const
  LSQL = ' SELECT                                       '+
         '   tarefa.identificacao                       '+
         ' from                                         '+
         '   tarefa                                     '+
         ' where                                        '+
         '   tarefa.identificacao = %s                  '+
         ' and                                          '+
         '   (tarefa.status = %s or tarefa.status = %s) ';
begin
  Result := not FConn.MakeQry.Open(
    Format(LSQL, [
      QuotedStr(AIdentification),
      QuotedStr(Ord(TTarefaStatusType.Processando).ToString),
      QuotedStr(Ord(TTarefaStatusType.Concluido).ToString)
    ])
  ).IsEmpty;
end;

function TTarefaRepository.Index: TObjectList<TTarefa>;
var
  lQry: IZLQry;
  lEntity: TTarefa;
begin
  Result := TObjectList<TTarefa>.Create;

  // Abrir SQL
  lQry := FConn.MakeQry.Open(
    TAREFA_SELECT_ALL + ' order by tarefa.idtarefa'
  );
  if lQry.IsEmpty then
    Exit;

  // Carregar dados para lista
  lQry.First;
  while not lQry.Eof do
  begin
    lEntity := TTarefa.Create;
    Result.Add(lEntity);
    DataSetToEntity(lQry.DataSet, lEntity);
    lQry.Next;
  end;
end;

class function TTarefaRepository.Make(AConn: IZLConnection): ITarefaRepository;
begin
  Result := Self.Create(AConn);
end;

function TTarefaRepository.ManageTransaction: Boolean;
begin
  Result := FManageTransaction;
end;

function TTarefaRepository.ManageTransaction(AValue: Boolean): ITarefaRepository;
begin
  Result := Self;
  FManageTransaction := AValue;
end;

function TTarefaRepository.Show(AId: Int64): TTarefa;
var
  lQry: IZLQry;
begin
  Result := nil;
  lQry := FConn.MakeQry.Open(
    Format(TAREFA_SELECT_ALL_WHERE_PK_EQUAL, [
      AId.ToString
    ])
  );
  if lQry.IsEmpty then
    Exit;

  Result := TTarefa.Create;
  DataSetToEntity(lQry.DataSet, Result);
end;

function TTarefaRepository.Store(AEntity: TTarefa): Int64;
begin
  Try
    if FManageTransaction then
      FConn.StartTransaction;

    // Tarefa
    Result := FConn.MakeQry.Open(
      Format(TAREFA_INSERT, [
        QuotedStr(AEntity.identificacao),
        QuotedStr(Ord(AEntity.status).ToString),
        QuotedStr(AEntity.mensagem),
        QuotedStr(FormatDateTime('yyyy-mm-dd', AEntity.dtinicio)),
        QuotedStr(FormatDateTime('yyyy-mm-dd', AEntity.dtfim))
      ])
    ).FieldByName('idtarefa').AsLargeInt;

    if FManageTransaction then
      FConn.CommitTransaction;
  except on E: Exception do
    Begin
      if FManageTransaction then
        FConn.RollBackTransaction;
      raise;
    end;
  end;
end;

function TTarefaRepository.Update(AId: Int64; AEntity: TTarefa): Boolean;
begin
  Try
    if FManageTransaction then
      FConn.StartTransaction;

    // Tarefa
    FConn.MakeQry.ExecSQL(Format(TAREFA_UPDATE, [
      QuotedStr(AEntity.identificacao),
      QuotedStr(Ord(AEntity.status).ToString),
      QuotedStr(AEntity.mensagem),
      QuotedStr(FormatDateTime('yyyy-mm-dd', AEntity.dtinicio)),
      QuotedStr(FormatDateTime('yyyy-mm-dd', AEntity.dtfim)),
      QuotedStr(AId.ToString)
    ]));

    if FManageTransaction then
      FConn.CommitTransaction;
  except on E: Exception do
    Begin
      if FManageTransaction then
        FConn.RollBackTransaction;
      raise;
    end;
  end;

  Result := True;
end;

end.
