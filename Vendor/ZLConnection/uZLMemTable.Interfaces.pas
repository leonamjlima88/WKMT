unit uZLMemTable.Interfaces;

interface

uses
  Data.DB;

type
  IZLMemTable = interface
    ['{A33A8267-08DE-482A-B9B4-984E3F6A81A4}']

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

end.
