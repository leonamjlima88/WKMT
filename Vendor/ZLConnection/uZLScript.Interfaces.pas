unit uZLScript.Interfaces;

interface

type
  IZLScript = interface
    ['{801CA8B3-2077-4635-A8A1-E34696612AEE}']

    function SQLScriptsClear: IZLScript;
    function SQLScriptsAdd(AValue: String): IZLScript;
    function ValidateAll: Boolean;
    function ExecuteAll: Boolean;
  end;

implementation

end.
