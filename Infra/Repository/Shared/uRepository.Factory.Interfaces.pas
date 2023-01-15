unit uRepository.Factory.Interfaces;

interface

uses
  uPessoa.Repository.Interfaces,
  uTarefa.Repository.Interfaces;

type
  IRepositoryFactory = Interface
    ['{FD106332-EA1E-402F-B535-67A30ACFAB78}']
    function Pessoa: IPessoaRepository;
    function Tarefa: ITarefaRepository;
  end;

implementation

end.
