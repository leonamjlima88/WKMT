unit uMain;

interface

Type
  TMain = class
    class procedure Start;
    class procedure RunServer;
    class procedure SetMiddlewares;
    class procedure SetReportMemoryLeak;
    class procedure SetRoutes;
    class procedure ConnectionParams(var ADatabase, AServer, AUserName, APassword, ADriverID, AVendorLib: String);
  end;

implementation

uses
  System.SysUtils,
  Horse,
  Horse.Jhonson,
  uPessoa.Controller;

const
  SERVER_PORT     = 9876;
  CONN_DATABASE   = 'postgres';
  CONN_SERVER     = 'localhost';
  CONN_USERNAME   = 'postgres';
  CONN_PASSWORD   = 'secret';
  CONN_DRIVER_ID  = 'PG';
  CONN_VENDOR_LIB = 'C:\Program Files\PostgreSQL\15\pgAdmin 4\bin\libpq.dll';

{ TMain }

class procedure TMain.Start;
begin
  SetReportMemoryLeak;
  SetMiddlewares;
  SetRoutes;
  RunServer;
end;

class procedure TMain.ConnectionParams(var ADatabase, AServer, AUserName, APassword, ADriverID, AVendorLib: String);
begin
  ADatabase  := CONN_DATABASE;
  AServer    := CONN_SERVER;
  AUserName  := CONN_USERNAME;
  APassword  := CONN_PASSWORD;
  ADriverID  := CONN_DRIVER_ID;
  AVendorLib := CONN_VENDOR_LIB;
end;

class procedure TMain.RunServer;
begin
  // Executar Servidor
  THorse.Listen(SERVER_PORT, procedure(Horse: THorse)
  begin
    Writeln(Format('Server is running on port: %d', [Horse.Port]));
    Readln;
  end);
end;

class procedure TMain.SetMiddlewares;
begin
  THorse
    .Use(Jhonson);
end;

class procedure TMain.SetReportMemoryLeak;
begin
  // Reportar MemoryLeak, necessário digitar STOP no console para ver memoryLeaks
  if (DebugHook <> 0) then
  begin
    IsConsole := False;
    ReportMemoryLeaksOnShutdown := true;
  end;
end;

class procedure TMain.SetRoutes;
begin
  // Método de Teste - PING
  THorse.Get(
    'ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end
  );

  uPessoa.Controller.Registry;
end;

end.
