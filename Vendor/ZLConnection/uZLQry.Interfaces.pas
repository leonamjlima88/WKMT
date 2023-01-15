unit uZLQry.Interfaces;

interface

uses
  Data.DB;

type
  IZLQry = Interface
    ['{DAA2CF91-1A34-4539-8191-5BFE8C9190C9}']

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

end.
