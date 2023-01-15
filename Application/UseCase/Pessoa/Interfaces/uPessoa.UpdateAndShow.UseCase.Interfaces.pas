unit uPessoa.UpdateAndShow.UseCase.Interfaces;

interface

uses
  uPessoa.Update.DTO,
  uPessoa.Show.DTO;

type
  IPessoaUpdateAndShowUseCase = Interface
    ['{DA287BD1-50ED-4BD4-BBB3-16C807F3B551}']
    function Execute(AId: Int64; AInput: TPessoaUpdateDTO): TPessoaShowDTO;
  end;

implementation

end.
