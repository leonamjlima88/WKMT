unit uTarefa;

interface

uses
  uBase.Entity,
  uTarefa.Status.Types;

type
  TTarefa = class(TBaseEntity)
  private
    Fidtarefa: Int64;
    Fstatus: TTarefaStatusType;
    Fidentificacao: String;
    Fmensagem: String;
    Fdtfim: TDateTime;
    Fdtinicio: TDateTime;
  public
    constructor Create;
    destructor Destroy; override;

    property idtarefa: Int64 read Fidtarefa write Fidtarefa;
    property identificacao: String read Fidentificacao write Fidentificacao;
    property status: TTarefaStatusType read Fstatus write Fstatus;
    property mensagem: String read Fmensagem write Fmensagem;
    property dtinicio: TDateTime read Fdtinicio write Fdtinicio;
    property dtfim: TDateTime read Fdtfim write Fdtfim;
  end;

implementation

{ TTarefa }

constructor TTarefa.Create;
begin
end;

destructor TTarefa.Destroy;
begin
  inherited;
end;

end.
