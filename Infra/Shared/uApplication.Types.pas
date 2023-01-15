unit uApplication.Types;

interface

const
  HTTP_OK = 200; // Sucesso e retorna conteudo
  HTTP_CREATED = 201; // Incluiu Novo Registro
  HTTP_ACCEPTED = 202; // Solicita��o recebida, aceita e est� sendo processada em segundo plano
  HTTP_NO_CONTENT = 204; // Sucesso e n�o retorna conte�do
  HTTP_BAD_REQUEST = 400; // Erro rastre�vel
  HTTP_NOT_FOUND = 404; // N�o encontrado HTTP_NOT_FOUND
  HTTP_INTERNAL_SERVER_ERROR = 500; // Erro n�o rastre�vel
  OOPS_MESSAGE = 'Oops. Algum erro aconteceu!';
  SUCCESS_MESSAGE = 'Opera��o realizada com sucesso.';
  OPERATION_WILL_BE_PERFORMED_IN_BACKGROUND = 'Opera��o est� sendo realizada em segundo plano';
  IS_NOT_ALLOWED_PROCESS_THE_SAME_TASK = 'N�o � permitido processar a mesma tarefa';

implementation

end.
