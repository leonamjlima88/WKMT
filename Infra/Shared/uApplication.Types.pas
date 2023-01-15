unit uApplication.Types;

interface

const
  HTTP_OK = 200; // Sucesso e retorna conteudo
  HTTP_CREATED = 201; // Incluiu Novo Registro
  HTTP_ACCEPTED = 202; // Solicitação recebida, aceita e está sendo processada em segundo plano
  HTTP_NO_CONTENT = 204; // Sucesso e não retorna conteúdo
  HTTP_BAD_REQUEST = 400; // Erro rastreável
  HTTP_NOT_FOUND = 404; // Não encontrado HTTP_NOT_FOUND
  HTTP_INTERNAL_SERVER_ERROR = 500; // Erro não rastreável
  OOPS_MESSAGE = 'Oops. Algum erro aconteceu!';
  SUCCESS_MESSAGE = 'Operação realizada com sucesso.';
  OPERATION_WILL_BE_PERFORMED_IN_BACKGROUND = 'Operação está sendo realizada em segundo plano';
  IS_NOT_ALLOWED_PROCESS_THE_SAME_TASK = 'Não é permitido processar a mesma tarefa';

implementation

end.
