unit uZLQry.FireDAC;

interface

uses
  uZLQry.Interfaces,
  FireDAC.Comp.Client,
  Data.DB;

type
  TZLQryFireDAC = class(TInterfacedObject, IZLQry)
  private
    FConnection: TFDConnection;
    FQry: TFDQuery;
    constructor Create(AConnection: TFDConnection);
  public
    class function Make(AConnection: TFDConnection): IZLQry;
    destructor Destroy; override;

    function Open(ASQL: String): IZLQry;
    function ExecSQL(ASQL: String): IZLQry;
    function DataSet: TDataSet;
    function Close: IZLQry;
    function Locate(AKeyFields, AKeyValues: String): Boolean;
    function IsEmpty: Boolean;
    function FieldByName(AValue: String): TField;
    function First: IZLQry;
    function Eof: Boolean;
    function Next: IZLQry;
  end;

implementation

uses
  System.SysUtils;

{ TZLQryFireDAC }

function TZLQryFireDAC.Close: IZLQry;
begin
  Result := Self;
  FQry.Close;
end;

constructor TZLQryFireDAC.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConnection     := AConnection;
  FQry            := TFDQuery.Create(nil);
  FQry.Connection := FConnection;
end;

function TZLQryFireDAC.DataSet: TDataSet;
begin
  Result := TDataSet(FQry);
end;

destructor TZLQryFireDAC.Destroy;
begin
  if Assigned(FQry) then FreeAndNil(FQry);

  inherited;
end;

function TZLQryFireDAC.Eof: Boolean;
begin
  Result := FQry.Eof;
end;

function TZLQryFireDAC.ExecSQL(ASQL: String): IZLQry;
begin
  Result := Self;

  if FQry.Active then
    FQry.Close;

  FQry.ExecSQL(ASQL);
end;

function TZLQryFireDAC.FieldByName(AValue: String): TField;
begin
  Result := FQry.FieldByName(AValue);
end;

function TZLQryFireDAC.First: IZLQry;
begin
  Result := Self;
  FQry.First;
end;

function TZLQryFireDAC.IsEmpty: Boolean;
begin
  Result := FQry.IsEmpty;
end;

function TZLQryFireDAC.Locate(AKeyFields, AKeyValues: String): Boolean;
begin
  Result := FQry.Locate(AKeyFields, AKeyValues, []);
end;

class function TZLQryFireDAC.Make(AConnection: TFDConnection): IZLQry;
begin
  Result := Self.Create(AConnection);
end;

function TZLQryFireDAC.Next: IZLQry;
begin
  Result := Self;
  FQry.Next;
end;

function TZLQryFireDAC.Open(ASQL: String): IZLQry;
begin
  Result := Self;

  if FQry.Active then
    FQry.Close;

  FQry.Open(ASQL);
end;

end.
