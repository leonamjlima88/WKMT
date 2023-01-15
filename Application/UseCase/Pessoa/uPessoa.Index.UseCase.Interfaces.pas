unit uPessoa.Index.UseCase.Interfaces;

interface

uses
  uPessoa.Show.DTO,
  System.Generics.Collections;

type
  IPessoaIndexUseCase = Interface
    ['{2AC985D5-E403-4572-8734-5B93D9F5EF38}']
    function Execute: TObjectList<TPessoaShowDTO>;
  end;

implementation

end.
