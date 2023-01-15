unit uHlp;

interface

uses
  System.JSON;

type
  THlp = class
  private
  public
    class function OnlyNumbers(const S: string): string;
    class function StrToJsonObject(AValue: String): TJSONObject;
  end;

implementation

uses
  System.SysUtils;

{ TUtl }

class function THlp.OnlyNumbers(const S: string): string;
var
  vText : PChar;
begin
  vText := PChar(S);
  Result := '';

  while (vText^ <> #0) do
  begin
    {$IFDEF UNICODE}
    if CharInSet(vText^, ['0'..'9']) then
    {$ELSE}
    if vText^ in ['0'..'9'] then
    {$ENDIF}
      Result := Result + vText^;

    Inc(vText);
  end;

  Result := Result.Trim;
end;

class function THlp.StrToJsonObject(AValue: String): TJSONObject;
begin
  Result := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(AValue), 0) as TJSONObject;
end;

end.
