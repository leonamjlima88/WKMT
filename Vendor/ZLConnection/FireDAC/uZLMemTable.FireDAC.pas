unit uZLMemTable.FireDAC;

interface

uses
  uZLMemTable.Interfaces,
  Data.DB,
  FireDAC.Comp.Client;

type
  TZLMemTableFireDAC = class(TInterfacedObject, IZLMemTable)
  private
    FMemTable: TFDMemTable;
    constructor Create;
  public
    destructor Destroy; override;
    class function Make: IZLMemTable;

    function FromDataSet(ADataSet: TDataSet): IZLMemTable;
    function DataSet: TDataSet;
    function FieldDefs: TFieldDefs;
    function CreateDataSet: IZLMemTable;
    function Active: Boolean; overload;
    function Active(AValue: Boolean): IZLMemTable; overload;
    function EmptyDataSet: IZLMemTable;
    function Locate(AKeyFields, AKeyValues: Variant): Boolean;
    function AddField(AFieldName: String; AFieldType: TFieldType; ASize: Integer = 0; AFieldKind: TFieldKind = fkData): IZLMemTable;
    function IndexFieldNames(AValue: String): IZLMemTable; overload;
    function IndexFieldNames: String; overload;
    function Append: IZLMemTable;
    function Edit: IZLMemTable;
    function Post: IZLMemTable;
    function Delete: IZLMemTable;
    function FieldByName(AValue: String): TField;
  end;

implementation

uses
  System.SysUtils;

{ TZLMemTableFireDAC }

function TZLMemTableFireDAC.Active(AValue: Boolean): IZLMemTable;
begin
  Result := Self;
  FMemTable.Active := AValue;
end;

function TZLMemTableFireDAC.AddField(AFieldName: String; AFieldType: TFieldType; ASize: Integer; AFieldKind: TFieldKind): IZLMemTable;
var
  lField: TField;
begin
  Result := Self;

  case AFieldType of
    ftString:   lField := TStringField.Create(FMemTable);
    ftSmallint: lField := TSmallintField.Create(FMemTable);
    ftInteger:  lField := TIntegerField.Create(FMemTable);
    ftBoolean:  lField := TBooleanField.Create(FMemTable);
    ftFloat:    lField := TFloatField.Create(FMemTable);
    ftCurrency: lField := TCurrencyField.Create(FMemTable);
    ftDate:     lField := TDateField.Create(FMemTable);
    ftDateTime: lField := TDateTimeField.Create(FMemTable);
    ftLargeint: lField := TLargeintField.Create(FMemTable);
  end;

  // Calculados
  lField.FieldName    := AFieldName;
  lField.DisplayLabel := AFieldName;
  lField.Size         := ASize;
  lField.Required     := False;
  lField.FieldKind    := AFieldKind;
  lField.DataSet      := FMemTable;
end;

function TZLMemTableFireDAC.Append: IZLMemTable;
begin
  Result := Self;
  FMemTable.Append;
end;

function TZLMemTableFireDAC.Active: Boolean;
begin
  Result := FMemTable.Active;
end;

constructor TZLMemTableFireDAC.Create;
begin
  inherited Create;
  FMemTable := TFDMemTable.Create(nil);
end;

function TZLMemTableFireDAC.CreateDataSet: IZLMemTable;
begin
  Result := Self;
  FMemTable.CreateDataSet;
end;

function TZLMemTableFireDAC.DataSet: TDataSet;
begin
  Result := TDataSet(FMemTable);
end;

function TZLMemTableFireDAC.Delete: IZLMemTable;
begin
  Result := Self;
  FMemTable.Delete;
end;

destructor TZLMemTableFireDAC.Destroy;
begin
  if Assigned(FMemTable) then FreeAndNil(FMemTable);

  inherited;
end;

function TZLMemTableFireDAC.Edit: IZLMemTable;
begin
  Result := Self;
  FMemTable.Edit;
end;

function TZLMemTableFireDAC.EmptyDataSet: IZLMemTable;
begin
  if FMemTable.Active then
    FMemTable.EmptyDataSet;
end;

function TZLMemTableFireDAC.FieldByName(AValue: String): TField;
begin
  Result := FMemTable.FieldByName(AValue);
end;

function TZLMemTableFireDAC.FieldDefs: TFieldDefs;
begin
  Result := FMemTable.FieldDefs;
end;

function TZLMemTableFireDAC.FromDataSet(ADataSet: TDataSet): IZLMemTable;
var
  lCloneSource: TFDMemTable;
  lI: Integer;
begin
  Result := Self;

  if not Assigned(FMemTable) then raise Exception.Create('FMemTable is null');
  if not Assigned(ADataSet)  then raise Exception.Create('ADataSet is null');
  if not ADataSet.Active     then raise Exception.Create('ADataSet is not active');

  Try
    lCloneSource := TFDMemTable.Create(nil);
    lCloneSource.CloneCursor(TFDMemTable(ADataSet), true);

    FMemTable.DisableControls;
    lCloneSource.DisableControls;

    // Limpar dados de Target se existir
    if FMemTable.Active then
    Begin
      FMemTable.EmptyDataSet;
      FMemTable.Close;
    End;

    // Cópia dos dados para Target
    FMemTable.Data := lCloneSource.Data;

    // Nenhum campo é readonly
    for lI := 0 to Pred(ADataSet.Fields.Count) do
      ADataSet.Fields[lI].ReadOnly := False;
  Finally
    FMemTable.EnableControls;
    lCloneSource.EnableControls;
    if Assigned(lCloneSource) then
      FreeAndNil(lCloneSource);
  End;
end;

function TZLMemTableFireDAC.IndexFieldNames: String;
begin
  Result := FMemTable.IndexFieldNames;
end;

function TZLMemTableFireDAC.IndexFieldNames(AValue: String): IZLMemTable;
begin
  Result := Self;
  FMemTable.IndexFieldNames := AValue;
end;

function TZLMemTableFireDAC.Locate(AKeyFields, AKeyValues: Variant): Boolean;
begin
  Result := FMemTable.Locate(AKeyFields, AKeyValues, [loCaseInsensitive]);
end;

class function TZLMemTableFireDAC.Make: IZLMemTable;
begin
  Result := Self.Create;
end;

function TZLMemTableFireDAC.Post: IZLMemTable;
begin
  Result := Self;
  FMemTable.Post;
end;

end.
