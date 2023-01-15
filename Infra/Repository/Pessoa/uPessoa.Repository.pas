unit uPessoa.Repository;

interface

uses
  uPessoa.Repository.Interfaces,
  uPessoa,
  uZLConnection.Interfaces,
  System.Generics.Collections,
  Data.DB,
  uEnderecoIntegracao;

type
  TPessoaRepository = class(TInterfacedObject, IPessoaRepository)
  private
    FConn: IZLConnection;
    FManageTransaction: Boolean;
    constructor Create(AConn: IZLConnection);
    function DataSetToEntity(ADts: TDataSet; AEntity: TPessoa): IPessoaRepository;
  public
    class function Make(AConn: IZLConnection): IPessoaRepository;
    function Show(AId: Int64): TPessoa;
    function Store(AEntity: TPessoa): Int64;
    function Update(AId: Int64; AEntity: TPessoa): Boolean;
    function Delete(AId: Int64): Boolean;
    function Index: TObjectList<TPessoa>;
    function StoreOrUpdateEnderecoIntegracao(AEntity: TEnderecoIntegracao): IPessoaRepository;

    function ManageTransaction(AValue: Boolean): IPessoaRepository; overload;
    function ManageTransaction: Boolean; overload;
    function Conn: IZLConnection;
  end;

implementation

uses
  uZLQry.Interfaces,
  System.SysUtils,
  uPessoa.FlNatureza.Types,
  uCpfCnpj.ValueObject;

const
  // PESSOA
  PESSOA_SELECT_ALL = ' SELECT                                         '+
                      '   pessoa.*,                                    '+
                      '   endereco.idendereco as endereco_idendereco,  '+
                      '   endereco.dscep      as endereco_dscep        '+
                      ' FROM                                           '+
                      '   pessoa                                       '+
                      ' inner join endereco                            '+
                      '         on endereco.idpessoa = pessoa.idpessoa ';

  PESSOA_SELECT_ALL_WHERE_PK_EQUAL = PESSOA_SELECT_ALL + ' WHERE pessoa.idpessoa = %s';

  PESSOA_INSERT = ' INSERT INTO pessoa                                             '+
                  '   (flnatureza, dsdocumento, nmprimeiro, nmsegundo, dtregistro) '+
                  ' VALUES(%s, %s, %s, %s, %s) RETURNING idpessoa                  ';

  PESSOA_UPDATE = ' UPDATE pessoa                                                  '+
                  ' SET flnatureza=%s, dsdocumento=%s, nmprimeiro=%s, nmsegundo=%s '+
                  ' WHERE idpessoa=%s                                              ';

  PESSOA_DELETE_WHERE_PK_EQUAL = ' DELETE FROM pessoa WHERE pessoa.idpessoa = %s ';


  // ENDERECO
  ENDERECO_INSERT = ' INSERT INTO endereco '+
                    '   (idpessoa, dscep)  '+
                    ' VALUES(%s, %s)       ';

  ENDERECO_DELETE_WHERE_IDPESSOA_EQUAL = ' DELETE FROM endereco WHERE endereco.idpessoa = %s ';

{ TPessoaRepository }

function TPessoaRepository.Conn: IZLConnection;
begin
  Result := FConn;
end;

constructor TPessoaRepository.Create(AConn: IZLConnection);
begin
  inherited Create;
  FConn := AConn;
  FManageTransaction := True;
end;

function TPessoaRepository.DataSetToEntity(ADts: TDataSet; AEntity: TPessoa): IPessoaRepository;
begin
  Result := Self;

  With AEntity do
  begin
    // Pessoa
    idpessoa    := ADts.FieldByName('idpessoa').AsLargeInt;
    flnatureza  := TPessoaFlNaturezaType(ADts.FieldByName('flnatureza').AsInteger);
    dsdocumento := TCpfCnpjValueObject.Make(ADts.FieldByName('dsdocumento').AsString);
    nmprimeiro  := ADts.FieldByName('nmprimeiro').AsString;
    nmsegundo   := ADts.FieldByName('nmsegundo').AsString;
    dtregistro  := ADts.FieldByName('dtregistro').AsDateTime;

    // Endereço
    endereco.idendereco := ADts.FieldByName('endereco_idendereco').AsLargeInt;
    endereco.idpessoa   := ADts.FieldByName('idpessoa').AsLargeInt;
    endereco.dscep      := ADts.FieldByName('endereco_dscep').AsString;
  end;
end;

function TPessoaRepository.Delete(AId: Int64): Boolean;
begin
  FConn.MakeQry.ExecSQL(
    Format(PESSOA_DELETE_WHERE_PK_EQUAL, [
      QuotedStr(AId.ToString)
    ])
  );
  Result := True;
end;

function TPessoaRepository.Index: TObjectList<TPessoa>;
var
  lQry: IZLQry;
  lEntity: TPessoa;
begin
  Result := TObjectList<TPessoa>.Create;

  // Abrir SQL
  lQry := FConn.MakeQry.Open(
    PESSOA_SELECT_ALL + ' order by pessoa.idpessoa'
  );
  if lQry.IsEmpty then
    Exit;

  // Carregar dados para lista
  lQry.First;
  while not lQry.Eof do
  begin
    lEntity := TPessoa.Create;
    Result.Add(lEntity);
    DataSetToEntity(lQry.DataSet, lEntity);
    lQry.Next;
  end;
end;

class function TPessoaRepository.Make(AConn: IZLConnection): IPessoaRepository;
begin
  Result := Self.Create(AConn);
end;

function TPessoaRepository.ManageTransaction: Boolean;
begin
  Result := FManageTransaction;
end;

function TPessoaRepository.ManageTransaction(AValue: Boolean): IPessoaRepository;
begin
  Result := Self;
  FManageTransaction := AValue;
end;

function TPessoaRepository.Show(AId: Int64): TPessoa;
var
  lQry: IZLQry;
begin
  Result := nil;
  lQry := FConn.MakeQry.Open(
    Format(PESSOA_SELECT_ALL_WHERE_PK_EQUAL, [
      AId.ToString
    ])
  );
  if lQry.IsEmpty then
    Exit;

  Result := TPessoa.Create;
  DataSetToEntity(lQry.DataSet, Result);
end;

function TPessoaRepository.Store(AEntity: TPessoa): Int64;
begin
  Try
    if FManageTransaction then
      FConn.StartTransaction;

    // Pessoa
    Result := FConn.MakeQry.Open(
      Format(PESSOA_INSERT, [
        QuotedStr(Ord(AEntity.flnatureza).ToString),
        QuotedStr(AEntity.dsdocumento.Value),
        QuotedStr(AEntity.nmprimeiro),
        QuotedStr(AEntity.nmsegundo),
        QuotedStr(FormatDateTime('yyyy-mm-dd', now))
      ])
    ).FieldByName('idpessoa').AsLargeInt;

    // Endereco
    FConn.MakeQry.ExecSQL(
      Format(ENDERECO_INSERT, [
        QuotedStr(Result.ToString),
        QuotedStr(AEntity.endereco.dscep)
      ])
    );

    if FManageTransaction then
      FConn.CommitTransaction;
  except on E: Exception do
    Begin
      if FManageTransaction then
        FConn.RollBackTransaction;
      raise;
    end;
  end;
end;

function TPessoaRepository.StoreOrUpdateEnderecoIntegracao(AEntity: TEnderecoIntegracao): IPessoaRepository;
const
  LSQL = ' SELECT                                '+
         '   endereco_integracao.idendereco      '+
         ' FROM                                  '+
         '   endereco_integracao                 '+
         ' WHERE                                 '+
         '   endereco_integracao.idendereco = %s ';

  LSQL_INSERT = ' INSERT INTO endereco_integracao                                       '+
                '   (idendereco, dsuf, nmcidade, nmbairro, nmlogradouro, dscomplemento) '+
                ' VALUES                                                                '+
                '   (%s, %s, %s, %s, %s, %s);                                           ';

  LSQL_UPDATE = ' UPDATE endereco_integracao                                               '+
                ' SET dsuf=%s, nmcidade=%s, nmbairro=%s, nmlogradouro=%s, dscomplemento=%s '+
                ' WHERE idendereco=%s                                                      ';
var
  lMustInsert: Boolean;
begin
  Result := Self;

  Try
    if FManageTransaction then
      FConn.StartTransaction;

    // Verificar se deve inserir/atualizar
    lMustInsert := FConn.MakeQry.Open(Format(LSQL, [
      QuotedStr(AEntity.idendereco.ToString)
    ])).IsEmpty;

    case lMustInsert of
      True: Begin
        FConn.MakeQry.ExecSQL(Format(LSQL_INSERT, [
          QuotedStr(AEntity.idendereco.ToString),
          QuotedStr(AEntity.dsuf),
          QuotedStr(AEntity.nmcidade),
          QuotedStr(AEntity.nmbairro),
          QuotedStr(AEntity.nmlogradouro),
          QuotedStr(AEntity.dscomplemento)
        ]));
      end;
      False: Begin
        FConn.MakeQry.ExecSQL(Format(LSQL_UPDATE, [
          QuotedStr(AEntity.dsuf),
          QuotedStr(AEntity.nmcidade),
          QuotedStr(AEntity.nmbairro),
          QuotedStr(AEntity.nmlogradouro),
          QuotedStr(AEntity.dscomplemento),
          QuotedStr(AEntity.idendereco.ToString)
        ]));
      end;
    end;

    if FManageTransaction then
      FConn.CommitTransaction;
  except on E: Exception do
    Begin
      if FManageTransaction then
        FConn.RollBackTransaction;
      raise;
    end;
  end;
end;

function TPessoaRepository.Update(AId: Int64; AEntity: TPessoa): Boolean;
begin
  Try
    if FManageTransaction then
      FConn.StartTransaction;

    // Pessoa
    FConn.MakeQry.ExecSQL(Format(PESSOA_UPDATE, [
      QuotedStr(Ord(AEntity.flnatureza).toString),
      QuotedStr(AEntity.dsdocumento.Value),
      QuotedStr(AEntity.nmprimeiro),
      QuotedStr(AEntity.nmsegundo),
      QuotedStr(AId.ToString)
    ]));

    // Endereco
    FConn.MakeQry.ExecSQL(
      Format(ENDERECO_DELETE_WHERE_IDPESSOA_EQUAL, [
        QuotedStr(AId.ToString)
      ])
    );
    FConn.MakeQry.ExecSQL(
      Format(ENDERECO_INSERT, [
        QuotedStr(AId.ToString),
        QuotedStr(AEntity.endereco.dscep)
      ])
    );

    if FManageTransaction then
      FConn.CommitTransaction;
  except on E: Exception do
    Begin
      if FManageTransaction then
        FConn.RollBackTransaction;
      raise;
    end;
  end;

  Result := True;
end;

end.
