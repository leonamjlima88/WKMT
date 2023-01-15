unit uTarefa.Repository.Interfaces;

interface

uses
  uTarefa,
  System.Generics.Collections,
  uZLConnection.Interfaces;

type
  ITarefaRepository = Interface
    ['{E310AD6D-CAE8-4C0C-A743-8105BC3E292C}']
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

end.
