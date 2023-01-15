unit uPessoa.Repository.Interfaces;

interface

uses
  uPessoa,
  System.Generics.Collections,
  uZLConnection.Interfaces,
  uEnderecoIntegracao;

type
  IPessoaRepository = Interface
    ['{1F7C3096-963C-49AA-B4CF-E5C3E4751BED}']
    function Show(AId: Int64): TPessoa;
    function Store(AEntity: TPessoa): Int64;
    function Update(AId: Int64; AEntity: TPessoa): Boolean;
    function Delete(AId: Int64): Boolean;
    function Index: TObjectList<TPessoa>;
    function StoreOrUpdateEnderecoIntegracao(AEntity: TEnderecoIntegracao): IPessoaRepository;

    function ManageTransaction(AValue: Boolean): IPessoaRepository; overload;
    function ManageTransaction: Boolean; overload;
    function Conn: IZLConnection;
  end;

implementation

end.
