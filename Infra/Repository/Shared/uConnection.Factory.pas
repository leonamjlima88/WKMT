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
  uZLConnection.FireDAC;

class function TConnectionFactory.Make: IZLConnection;
begin
  Result := TZLConnectionFireDAC.Make(
    'postgres',
    'localhost',
    'postgres',
    'secret',
    'PG',
    'C:\Program Files\PostgreSQL\15\pgAdmin 4\bin\libpq.dll'
  );
end;

end.
