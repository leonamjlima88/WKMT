unit uConnection.Factory;

interface

uses
  uZLConnection.Interfaces;

type
  TConnectionFactory = class
  private
  public
    class function Make: IZLConnection;
  end;

implementation

{ TConnectionFactory }

uses
  uZLConnection.FireDAC,
  uMain;

class function TConnectionFactory.Make: IZLConnection;
var
  lDatabase, lServer, lUserName, lPassword, lDriverID, lVendorLib: String;
begin
  TMain.ConnectionParams(lDatabase, lServer, lUserName, lPassword, lDriverID, lVendorLib);
  Result := TZLConnectionFireDAC.Make(lDatabase, lServer, lUserName, lPassword, lDriverID, lVendorLib);
end;

end.
