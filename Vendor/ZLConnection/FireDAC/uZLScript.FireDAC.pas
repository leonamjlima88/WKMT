unit uZLScript.FireDAC;

interface

uses
  FireDAC.UI.Intf, FireDAC.Stan.Async, FireDAC.Comp.ScriptCommands, FireDAC.Stan.Util,
  FireDAC.Stan.Intf, FireDAC.Comp.Script, FireDAC.Comp.Client,

  uZLScript.Interfaces;

type
  TZLScriptFireDAC = class(TInterfacedObject, IZLScript)
  private
    FConnection: TFDConnection;
    FScript: TFDScript;
    constructor Create(AConnection: TFDConnection);
  public
    destructor Destroy; override;
    class function Make(AConnection: TFDConnection): IZLScript;

    function SQLScriptsClear: IZLScript;
    function SQLScriptsAdd(AValue: String): IZLScript;
    function ValidateAll: Boolean;
    function ExecuteAll: Boolean;
  end;

implementation

uses
  System.SysUtils;

{ TZLScriptFireDAC }

constructor TZLScriptFireDAC.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConnection        := AConnection;
  FScript            := TFDScript.Create(nil);
  FScript.Connection := FConnection;
end;

destructor TZLScriptFireDAC.Destroy;
begin
  if Assigned(FScript) then FreeAndNil(FScript);

  inherited;
end;

function TZLScriptFireDAC.ExecuteAll: Boolean;
begin
  Result := FScript.ExecuteAll;
end;

class function TZLScriptFireDAC.Make(AConnection: TFDConnection): IZLScript;
begin
  Result := Self.Create(AConnection);
end;

function TZLScriptFireDAC.SQLScriptsAdd(AValue: String): IZLScript;
begin
  Result := Self;
  FScript.SQLScripts.Add;
  FScript.SQLScripts.Items[Pred(FScript.SQLScripts.Count)].SQL.Text := AValue;
end;

function TZLScriptFireDAC.SQLScriptsClear: IZLScript;
begin
  Result := Self;
  FScript.SQLScripts.Clear;
end;

function TZLScriptFireDAC.ValidateAll: Boolean;
begin
  Result := FScript.ValidateAll;
end;

end.
