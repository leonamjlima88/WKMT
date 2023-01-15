unit uRes;

interface

uses
  Horse.Response,
  uApplication.Types,
  uResObject;

type
  TRes = class
  private
  public
    class procedure Send(
      const ARes: THorseResponse;
      const AData: TObject; 
      AHttpCode: SmallInt = HTTP_OK;
      AMessage: String = '';
      AContentType: String = 'application/json'
    ); overload;
  end;

implementation

uses
  System.SysUtils,
  uSmartPointer;

{ TRes }

class procedure TRes.Send(const ARes: THorseResponse; const AData: TObject; AHttpCode: SmallInt; AMessage, AContentType: String);
var
  lOutput: Shared<TResObject>;
  lIsAnError: Boolean;
begin
  if AMessage.Trim.IsEmpty then
  begin
    lIsAnError := (AHttpCode = HTTP_BAD_REQUEST) or (AHttpCode = HTTP_INTERNAL_SERVER_ERROR);
    case lIsAnError of
      True:  AMessage := OOPS_MESSAGE;
      False: AMessage := SUCCESS_MESSAGE;
    end;
  end;

  lOutput := TResObject.Create;
  With lOutput.Value do
  begin
    Code     := AHttpCode;
    Error    := False;
    &Message := AMessage;
    Data     := AData;
  end;

  ARes
    .ContentType (AContentType)
    .Send        (lOutput.Value.ToJsonObject)
    .Status      (AHttpCode);
end;

end.
