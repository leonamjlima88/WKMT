unit uZLConnection.FireDAC;

interface

uses
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Comp.UI,
  System.Classes,

  uZLConnection.Interfaces,
  uZLQry.Interfaces,
  uZLScript.Interfaces,
  uZLConnection.Types;

type
  TZLConnectionFireDAC = class(TInterfacedObject, IZLConnection)
  private
    FConn: TFDConnection;
    FMySQLDriverLink: TFDPhysMySQLDriverLink;
    FConnectionType: TZLConnLibType;
    FDriverDB: TZLDriverDB;
    FDatabase,
    FServer,
    FUserName,
    FPassword,
    FDriverID,
    FVendorLib: String;
    constructor Create(ADatabase, AServer, AUserName, APassword, ADriverID, AVendorLib: String);
    function SetUp: IZLConnection;
  public
    destructor Destroy; override;
    class function Make(ADatabase, AServer, AUserName, APassword, ADriverID, AVendorLib: String): IZLConnection;

    function ConnectionType: TZLConnLibType;
    function DriverDB: TZLDriverDB;
    function DataBaseName: String;
    function IsConnected: Boolean;
    function Connect: IZLConnection;
    function Disconnect: IZLConnection;
    function MakeQry: IZLQry;
    function MakeScript: IZLScript;
    function Instance: TComponent;
    function InTransaction: Boolean;
    function StartTransaction: IZLConnection;
    function CommitTransaction: IZLConnection;
    function RollBackTransaction: IZLConnection;
  end;

implementation

uses
  System.SysUtils,
  uZLQry.FireDAC,
  uZLScript.FireDAC;

{ TConnection }

function TZLConnectionFireDAC.CommitTransaction: IZLConnection;
begin
  Result := Self;
  if FConn.InTransaction then
    FConn.Commit;
end;

function TZLConnectionFireDAC.Connect: IZLConnection;
begin
  Result := Self;
  FConn.Connected := True;
end;

function TZLConnectionFireDAC.ConnectionType: TZLConnLibType;
begin
  Result := ctFireDAC;
end;

constructor TZLConnectionFireDAC.Create(ADatabase, AServer, AUserName, APassword, ADriverID, AVendorLib: String);
begin
  inherited Create;

  FConn            := TFDConnection.Create(nil);
  FMySQLDriverLink := TFDPhysMySQLDriverLink.Create(nil);
  FDatabase        := ADatabase;
  FServer          := AServer;
  FUserName        := AUserName;
  FPassword        := APassword;
  FDriverID        := ADriverID;
  FVendorLib       := AVendorLib;
  SetUp;
end;

function TZLConnectionFireDAC.DataBaseName: String;
begin
  Result := FConn.Params.Database;
end;

destructor TZLConnectionFireDAC.Destroy;
begin
  if Assigned(FConn)            then FreeAndNil(FConn);
  if Assigned(FMySQLDriverLink) then FreeAndNil(FMySQLDriverLink);

  inherited;
end;

function TZLConnectionFireDAC.Disconnect: IZLConnection;
begin
  Result := Self;
  FConn.Connected := False;
end;

function TZLConnectionFireDAC.DriverDB: TZLDriverDB;
begin
  Result := FDriverDB;
end;

function TZLConnectionFireDAC.Instance: TComponent;
begin
  Result := FConn;
end;

function TZLConnectionFireDAC.InTransaction: Boolean;
begin
  Result := FConn.InTransaction;
end;

function TZLConnectionFireDAC.IsConnected: Boolean;
begin
  Result := FConn.Connected;
end;

class function TZLConnectionFireDAC.Make(ADatabase, AServer, AUserName, APassword, ADriverID, AVendorLib: String): IZLConnection;
begin
  Result := Self.Create(ADatabase, AServer, AUserName, APassword, ADriverID, AVendorLib);
end;

function TZLConnectionFireDAC.MakeQry: IZLQry;
begin
  Result := TZLQryFireDAC.Make(FConn);
end;

function TZLConnectionFireDAC.MakeScript: IZLScript;
begin
  Result := TZLScriptFireDAC.Make(FConn);
end;

function TZLConnectionFireDAC.RollBackTransaction: IZLConnection;
begin
  Result := Self;
  FConn.Rollback;
end;

function TZLConnectionFireDAC.SetUp: IZLConnection;
begin
  Result := Self;
  With FConn.Params do
  begin
    Clear;
    Add('Database='  + FDatabase);
    Add('Server='    + FServer);
    Add('User_Name=' + FUserName);
    Add('Password='  + FPassword);
    Add('DriverID='  + FDriverID);
  end;
  FConn.LoginPrompt          := False;
  FMySQLDriverLink.VendorLib := FVendorLib;

  if (FDriverID.ToLower = 'mysql') then
    FDriverDB := ddMySql;
end;

function TZLConnectionFireDAC.StartTransaction: IZLConnection;
begin
  Result := Self;
  if not FConn.InTransaction then
    FConn.StartTransaction;
end;

end.
