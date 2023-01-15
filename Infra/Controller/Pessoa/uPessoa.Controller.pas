unit uPessoa.Controller;

interface

procedure Registry;

implementation

uses
  Horse,
  REST.Json,
  System.JSON,
  System.SysUtils,
  uRepository.Factory,
  uPessoa.Store.DTO,
  uPessoa.Show.DTO,
  uPessoa.Update.DTO,
  uPessoa.Show.UseCase,
  uPessoa.StoreAndShow.UseCase,
  uPessoa.UpdateAndShow.UseCase,
  uPessoa.Delete.UseCase,
  uPessoa.Index.UseCase,
  uPessoa.Mapper,
  System.Generics.Collections,
  uRes,
  uApplication.Types,
  uHlp,
  uSmartPointer,
  uPessoa.StoreBatch.DTO,
  uPessoa.StoreBatch.UseCase,
  System.Threading,
  uTarefa.Repository.Interfaces,
  uPessoa.UpdateAddressWithViaCep.UseCase;

procedure Index(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lOutputList: Shared<TObjectList<TPessoaShowDTO>>;
begin
  Try
    // Listar registros
    lOutputList := TPessoaIndexUseCase
      .Make(TRepositoryFactory.Make.Pessoa)
      .Execute;

    // Retorno
    TRes.Send(Res, lOutputList);
  except on E: Exception do
    TRes.Send(Res, Nil, HTTP_BAD_REQUEST, E.Message);
  end;
end;

procedure Show(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lId: Int64;
  lOutput: Shared<TPessoaShowDTO>;
begin
  Try
    lId := StrToInt64Def(Req.Params['id'],0);

    // Localizar
    lOutput := TPessoaShowUseCase
      .Make    (TRepositoryFactory.Make.Pessoa)
      .Execute (lId);

    // Retorno
    case Assigned(lOutput.Value) of
      True:  TRes.Send(Res, lOutput);
      False: TRes.Send(Res, nil, HTTP_NOT_FOUND)
    end;
  except on E: Exception do
    TRes.Send(Res, Nil, HTTP_BAD_REQUEST, E.Message);
  end;
end;

procedure Store(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lInput: Shared<TPessoaStoreDTO>;
  lOutput: Shared<TPessoaShowDTO>;
begin
  Try
    // Mapear Body para DTO de entrada
    lInput := TJson.JsonToObject<TPessoaStoreDTO>(Req.Body);

    // Inserir e retornar registro inserido
    lOutput := TPessoaStoreAndShowUseCase
      .Make    (TRepositoryFactory.Make.Pessoa)
      .Execute (lInput);

    // Retorno
    TRes.Send(Res, lOutput, HTTP_CREATED);
  except on E: Exception do
    TRes.Send(Res, nil, HTTP_BAD_REQUEST, E.Message);
  end;
end;

procedure StoreBatch(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lIdentification: String;
  lInput: Shared<TPessoaStoreBatchDTO>;
  lRepositoryTarefa: ITarefaRepository;
begin
  Try
    lIdentification := Req.Params['identification'];

    // Se existir uma tarefa processando ou concluída, não deve prosseguir
    lRepositoryTarefa := TRepositoryFactory.Make.Tarefa;
    if lRepositoryTarefa.ExistsStatusLikeProcessOrFinished(lIdentification) then
    begin
      TRes.Send(Res, nil, HTTP_BAD_REQUEST, IS_NOT_ALLOWED_PROCESS_THE_SAME_TASK + ': ' + lIdentification);
      Exit;
    end;

    // Mapear Body para DTO de entrada
    lInput := TPessoaStoreBatchDTO.FromJsonString(lIdentification, Req.Body);

    // Inserir lote de registros
    TTask.Run(
      procedure
      begin
        TPessoaStoreBatchUseCase
          .Make    (TRepositoryFactory.Make.Pessoa, lRepositoryTarefa)
          .Execute (lInput);
      end
    );

    // Retorno
    TRes.Send(Res, nil, HTTP_ACCEPTED, OPERATION_WILL_BE_PERFORMED_IN_BACKGROUND);
  except on E: Exception do
    TRes.Send(Res, nil, HTTP_BAD_REQUEST, E.Message);
  end;
end;

procedure Update(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lId: Int64;
  lInput: Shared<TPessoaUpdateDTO>;
  lOutput: Shared<TPessoaShowDTO>;
begin
  Try
    // Mapear Body para DTO de entrada
    lId    := StrToInt64Def(Req.Params['id'],0);
    lInput := TJson.JsonToObject<TPessoaUpdateDTO>(Req.Body);

    // Inserir e retornar registro inserido
    lOutput := TPessoaUpdateAndShowUseCase
      .Make    (TRepositoryFactory.Make.Pessoa)
      .Execute (lId, lInput);

    // Retorno
    TRes.Send(Res, lOutput);
  except on E: Exception do
    TRes.Send(Res, nil, HTTP_BAD_REQUEST, E.Message);
  end;
end;

procedure UpdateAddressWithViaCep(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  try
    // Atualizar endereços com ViaCep
    TTask.Run(
      procedure
      begin
        TPessoaUpdateAddressWithViaCepUseCase
          .Make(TRepositoryFactory.Make.Pessoa)
          .Execute;
      end
    );

    TRes.Send(Res, nil, HTTP_ACCEPTED, OPERATION_WILL_BE_PERFORMED_IN_BACKGROUND);
  except on E: Exception do
    TRes.Send(Res, nil, HTTP_BAD_REQUEST, E.Message);
  end;
end;

procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lId: Int64;
begin
  Try
    lId := StrToInt64Def(Req.Params['id'],0);
    TPessoaDeleteUseCase
      .Make    (TRepositoryFactory.Make.Pessoa)
      .Execute (lId);
  except on E: Exception do
    TRes.Send(Res, nil, HTTP_BAD_REQUEST, E.Message);
  end;
end;

procedure Registry;
begin
  THorse.Get('/pessoas', Index);
  THorse.Get('/pessoas/:id', Show);
  THorse.Post('/pessoas', Store);
  THorse.Put('/pessoas/:id', Update);
  THorse.Delete('/pessoas/:id', Delete);
  THorse.Post('/pessoas/batch/:identification', StoreBatch);
  THorse.Put('/pessoas/update/address_with_viacep', UpdateAddressWithViaCep);
end;

end.
