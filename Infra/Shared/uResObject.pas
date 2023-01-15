unit uResObject;

interface

uses
  REST.Json,
  System.JSON;

type
  TResObject = class
  private
    FCode: SmallInt;
    FMessage: String;
    FError: Boolean;
    FData: TObject;
  public
    property Code: SmallInt read FCode write FCode;
    property Error: Boolean read FError write FError;
    property &Message: String read FMessage write FMessage;
    property Data: TObject read FData write FData;

    function ToJsonObject: TJsonObject;
  end;

implementation

{ TResObject }

function TResObject.ToJsonObject: TJsonObject;
begin
  Result := TJson.ObjectToJsonObject(Self);
end;

end.
