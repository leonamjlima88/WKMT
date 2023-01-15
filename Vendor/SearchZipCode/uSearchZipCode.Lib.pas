unit uSearchZipCode.Lib;

interface

uses
  IPPeerClient,
  REST.Client,
  Data.Bind.Components,
  Data.Bind.ObjectScope;

type
  TResponseData = record
    Zipcode: string;
    Address: string;
    District: string;
    City: string;
    State: string;
    Country: string;
    CityIbgeCode: string;
    StateIbgeCode: string;
    CountryIbgeCode: string;
  end;

  ISearchZipcodeLib = interface
    ['{272CE2E6-1D2C-4731-B3DF-6D6BA650B5C0}']

    function Execute(AZipcode: String): ISearchZipcodeLib;
    function ResponseData: TResponseData;
    function ResponseError: String;
  end;

  TSearchZipcodeLib = class(TInterfacedObject, ISearchZipcodeLib)
  protected
    FZipcode: String;
    FResource: String;
    FResponseData: TResponseData;
    FResponseError: String;
    FRestClient: TRESTClient;
    FRestRequest: TRESTRequest;
    FRestResponse: TRESTResponse;
  private
    function ValidateZipcode: ISearchZipcodeLib;
    function DoRequest: ISearchZipCodeLib;
    function DoFillResponseData(AJsonString: String): TSearchZipCodeLib;
    function RemoveDots(Str: String): String;
  public
    constructor Create;
    destructor Destroy; override;
    class function Make: ISearchZipcodeLib;

    function Execute(AZipcode: String): ISearchZipcodeLib;
    function ResponseData: TResponseData;
    function ResponseError: String;
  end;

implementation

uses
  System.SysUtils,
  REST.Types,
  System.JSON;

{ TSearchZipcodeLib }

constructor TSearchZipcodeLib.Create;
begin
  FRestClient                     := TRESTClient.Create('viacep.com.br/ws/');
  FRestClient.Accept              := 'application/json, text/plain; q=0.9, text/html;q=0.8,';
  FRestClient.AcceptCharset       := 'UTF-8, *;q=0.8';
  FRestClient.HandleRedirects     := True;
  FRestClient.RaiseExceptionOn500 := False;
  FRestResponse                   := TRESTResponse.Create(nil);
  FRestResponse.ContentType       := 'application/json';
  FRestRequest                    := TRESTRequest.Create(nil);
  FRestRequest.Client             := FRestClient;
  FRestRequest.Response           := FRestResponse;
  FRestRequest.SynchronizedEvents := False;
  FRestRequest.Method             := rmGET;
end;

destructor TSearchZipcodeLib.Destroy;
begin
  inherited;
  if Assigned(FRestClient)   then FRestClient.Free;
  if Assigned(FRestRequest)  then FRestRequest.Free;
  if Assigned(FRestResponse) then FRestResponse.Free;
end;

function TSearchZipcodeLib.DoFillResponseData(AJsonString: String): TSearchZipCodeLib;
var
  lJsonObject: TJSONObject;
begin
  Try
    lJsonObject := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(AJsonString), 0) as TJSONObject;
    With FResponseData do
    begin
      Address         := lJsonObject.Get('logradouro').JsonValue.Value;
      District        := UpperCase(lJsonObject.Get('bairro').JsonValue.Value);
      City            := lJsonObject.Get('localidade').JsonValue.Value;
      State           := lJsonObject.Get('uf').JsonValue.Value;
      CityIbgeCode    := lJsonObject.Get('ibge').JsonValue.Value;
      Zipcode         := FZipcode.Trim;
      Country         := 'Brasil';
      CountryIbgeCode := '1058';
      StateIbgeCode   := Copy(FResponseData.CityIbgeCode.Trim,1,2);
    end;
  finally
    lJsonObject.Free;
  end;
end;

function TSearchZipcodeLib.DoRequest: ISearchZipCodeLib;
begin
  FRestRequest.Resource := FResource;
  FRestRequest.Execute;
  case (FRestResponse.StatusCode = 200) and not(Utf8ToAnsi(FRestResponse.Content) = '{'#$A'  "erro": true'#$A'}') of
    True:  DoFillResponseData(FRestResponse.Content);
    False: Begin
      FResponseError := 'Cep ' + FZipcode + ' não encontrado.';
      Exit;
    end;
  end;
end;

function TSearchZipcodeLib.RemoveDots(Str: String): String;
var
  i: Integer;
  xStr: String;
begin
  xStr := '';
  for I := 1 to Length(Trim(Str)) do
    if (Pos(Copy(str,i,1),'/-.)(,|')=0) then xStr := xStr + str[i];

  xStr := StringReplace(xStr, ' ','',[rfReplaceAll]);

  Result := xStr.Trim;
end;


function TSearchZipcodeLib.ResponseData: TResponseData;
begin
  Result := FResponseData;
end;

function TSearchZipcodeLib.ResponseError: String;
begin
  Result := FResponseError;
end;

function TSearchZipcodeLib.ValidateZipcode: ISearchZipcodeLib;
begin
  // Validar Cep
  FZipCode := Copy(RemoveDots(FZipCode),1,8);
  If not (Length(FZipCode) = 8) then
  begin
    FResponseError := 'Cep ' + FZipcode + ' é Inválido.';
    Exit;
  end;
end;

function TSearchZipcodeLib.Execute(AZipcode: String): ISearchZipcodeLib;
begin
  Result         := Self;
  FZipcode       := AZipcode;
  FResource      := FZipcode.Trim+'/json/';
  FResponseError := EmptyStr;

  // Validar Cep
  ValidateZipcode;
  if not FResponseError.IsEmpty then
    Exit;

  // Efetuar Requisição
  DoRequest;
end;

class function TSearchZipcodeLib.Make: ISearchZipcodeLib;
begin
  Result := Self.Create;
end;

end.
