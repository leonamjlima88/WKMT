unit uPessoa.StoreBatch.UseCase.Interfaces;

interface

uses
  uPessoa.StoreBatch.DTO;

type
  IPessoaStoreBatchUseCase = Interface
    ['{4C2EFC09-B835-4826-BAA4-B460C5E43FCA}']
    function Execute(AInput: TPessoaStoreBatchDTO): IPessoaStoreBatchUseCase;
  end;

implementation

end.
