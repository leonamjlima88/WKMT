unit uPessoa.UpdateAddressWithViaCep.UseCase;

interface

uses
  uPessoa.UpdateAddressWithViaCep.UseCase.Interfaces,
  uPessoa.Repository.Interfaces,
  uSearchZipCode.Lib;

type
  TPessoaUpdateAddressWithViaCepUseCase = class(TInterfacedObject, IPessoaUpdateAddressWithViaCepUseCase)
  private
    FRepository: IPessoaRepository;
    FSearchZipCodeLib: ISearchZipcodeLib;
    constructor Create(ARepository: IPessoaRepository);
  public
    class function Make(ARepository: IPessoaRepository): IPessoaUpdateAddressWithViaCepUseCase;
    function Execute: IPessoaUpdateAddressWithViaCepUseCase;
  end;

implementation

uses
  uSmartPointer,
  System.Generics.Collections,
  uPessoa,
  System.SysUtils,
  uHlp,
  uEnderecoIntegracao;

{ TPessoaUpdateAddressWithViaCepUseCase }

constructor TPessoaUpdateAddressWithViaCepUseCase.Create(ARepository: IPessoaRepository);
begin
  inherited Create;
  FRepository := ARepository;
  FRepository.ManageTransaction(False);
  FSearchZipCodeLib := TSearchZipcodeLib.Make;
end;

function TPessoaUpdateAddressWithViaCepUseCase.Execute: IPessoaUpdateAddressWithViaCepUseCase;
var
  lEntityList: Shared<TObjectList<TPessoa>>;
  lItem: TPessoa;
  lEnderecoIntegracao: Shared<TEnderecoIntegracao>;
  lLib: ISearchZipCodeLib;
begin
  // Localizar dados
  lEntityList := FRepository.Index;

  Try
    FRepository.Conn.StartTransaction;

    for lItem in lEntityList.Value do
    begin
      // Não proceder se cep invalido
      if (THlp.OnlyNumbers(lItem.endereco.dscep).Trim.Length <> 8) then
        continue;

      // Localizar dados referente ao cep informado
      FSearchZipCodeLib.Execute(lItem.endereco.dscep);
      if not FSearchZipCodeLib.ResponseError.Trim.IsEmpty then
        continue;

      // Atualizar endereço de integração
      lEnderecoIntegracao := TEnderecoIntegracao.Create;
      With lEnderecoIntegracao.Value do
      begin
        idendereco    := lItem.endereco.idendereco;
        dsuf          := FSearchZipCodeLib.ResponseData.State;
        nmcidade      := FSearchZipCodeLib.ResponseData.City;
        nmbairro      := FSearchZipCodeLib.ResponseData.District;
        nmlogradouro  := FSearchZipCodeLib.ResponseData.Address;
      end;
      FRepository.StoreOrUpdateEnderecoIntegracao(lEnderecoIntegracao);
    end;

    FRepository.Conn.CommitTransaction;
  except on E: Exception do
    Begin
      FRepository.Conn.RollBackTransaction;
      raise;
    end;
  end;
end;

class function TPessoaUpdateAddressWithViaCepUseCase.Make(ARepository: IPessoaRepository): IPessoaUpdateAddressWithViaCepUseCase;
begin
  Result := Self.Create(ARepository);
end;

end.
