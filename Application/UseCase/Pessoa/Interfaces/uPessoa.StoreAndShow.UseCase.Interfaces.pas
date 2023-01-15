unit uPessoa.StoreAndShow.UseCase.Interfaces;

interface

uses
  uPessoa.Store.DTO,
  uPessoa.Show.DTO;

type
  IPessoaStoreAndShowUseCase = Interface
    ['{13B16DFE-E8B8-4C54-BBCB-4F323C3496A0}']
    function Execute(AInput: TPessoaStoreDTO): TPessoaShowDTO;
  end;

implementation

end.
