unit uMain;

interface

Type
  TMain = class
    class procedure Start;
    class procedure RunServer;
    class procedure SetMiddlewares;
    class procedure SetReportMemoryLeak;
    class procedure SetRoutes;
  end;

implementation

uses
  System.SysUtils,
  Horse,
  Horse.Jhonson,
  uPessoa.Controller;

const
  SERVER_PORT = 9876;

{ TMain }

class procedure TMain.Start;
begin
  SetReportMemoryLeak;
  SetMiddlewares;
  SetRoutes;
  RunServer;
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
