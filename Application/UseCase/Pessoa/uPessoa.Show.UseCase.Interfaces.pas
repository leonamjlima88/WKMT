unit uPessoa.Show.UseCase.Interfaces;

interface

uses
  uPessoa.Show.DTO;

type
  IPessoaShowUseCase = Interface
    ['{542E236B-ED46-4205-996B-E127A6B34BA4}']
    function Execute(AId: Int64): TPessoaShowDTO;
  end;

implementation

end.
